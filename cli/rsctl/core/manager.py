"""
ServiceManager refatorado com arquitetura profissional
"""

import subprocess
import time
from pathlib import Path
from typing import Dict, List, Optional, Any

from ..utils import (
    get_logger,
    fmt,
    ServiceNotFoundError,
    ServiceStartError,
    ServiceStopError,
    ServiceCheckError,
    CommandExecutionError,
    DependencyError,
    PlatformDetector,
)
from .config import ConfigManager
from .cache import CacheManager
from .validator import ServiceValidator, DependencyChecker

logger = get_logger(__name__)


class ServiceManager:
    """
    Gerencia serviços do servidor remoto com arquitetura profissional.
    
    Features:
    - Cache inteligente para performance
    - Validações robustas
    - Logging profissional
    - Tratamento de erros completo
    - Verificações paralelas quando possível
    """
    
    def __init__(
        self,
        config_path: Optional[Path] = None,
        cache_ttl: float = 5.0,
        enable_cache: bool = True
    ):
        """
        Inicializa o gerenciador de serviços.
        
        Args:
            config_path: Caminho opcional para arquivo de configuração
            cache_ttl: TTL do cache em segundos
            enable_cache: Se True, habilita cache
        """
        self.config_manager = ConfigManager(config_path)
        self.cache = CacheManager() if enable_cache else None
        self.cache_ttl = cache_ttl
        self.logs_dir = Path(__file__).parent.parent.parent.parent / "logs"
        self.logs_dir.mkdir(exist_ok=True)
        
        logger.info("ServiceManager inicializado")
    
    @property
    def config(self) -> Dict[str, Any]:
        """Acesso à configuração"""
        return self.config_manager.config
    
    def _run_command(
        self,
        cmd: List[str],
        check: bool = False,
        capture_output: bool = True,
        timeout: int = 30,
        needs_sudo: bool = False
    ) -> subprocess.CompletedProcess:
        """
        Executa comando shell com tratamento robusto de erros.
        
        Args:
            cmd: Comando a executar
            check: Se True, levanta exceção em caso de erro
            capture_output: Se True, captura stdout/stderr
            timeout: Timeout em segundos
            needs_sudo: Se True, adiciona sudo ao comando
            
        Returns:
            CompletedProcess com resultado
            
        Raises:
            CommandExecutionError: Se o comando falhar
        """
        # Sudo apenas em sistemas Unix-like
        if needs_sudo and PlatformDetector.is_unix_like():
            cmd = ["sudo"] + cmd
        # Windows não usa sudo, mas pode precisar de elevação (UAC)
        # Isso é tratado pelo sistema operacional automaticamente
        
        logger.debug(f"Executando comando: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(
                cmd,
                check=check,
                capture_output=capture_output,
                text=True,
                timeout=timeout
            )
            return result
        except subprocess.TimeoutExpired:
            raise CommandExecutionError(
                f"Comando expirou após {timeout}s",
                command=' '.join(cmd),
                exit_code=-1
            )
        except subprocess.CalledProcessError as e:
            raise CommandExecutionError(
                f"Comando falhou: {e.stderr or 'Erro desconhecido'}",
                command=' '.join(cmd),
                exit_code=e.returncode
            )
        except FileNotFoundError:
            raise CommandExecutionError(
                f"Comando não encontrado: {cmd[0]}",
                command=' '.join(cmd),
                exit_code=-1
            )
    
    def _check_service_running(self, service_name: str, use_cache: bool = True) -> bool:
        """
        Verifica se um serviço está rodando.
        
        Args:
            service_name: Nome do serviço
            use_cache: Se True, usa cache quando disponível
            
        Returns:
            True se o serviço está rodando
            
        Raises:
            ServiceCheckError: Se houver erro ao verificar
        """
        # Verificar cache
        if use_cache and self.cache:
            cached = self.cache.get(f"status:{service_name}")
            if cached is not None:
                logger.debug(f"Status de {service_name} obtido do cache")
                return cached
        
        service_config = self.config.get("services", {}).get(service_name, {})
        if not service_config:
            raise ServiceNotFoundError(f"Serviço '{service_name}' não encontrado")
        
        check_type = service_config.get("check_type", "process")
        is_running = False
        
        try:
            if check_type == "systemd":
                service_name_systemd = service_config.get("systemd_name", service_name)
                result = self._run_command(
                    ["systemctl", "is-active", "--quiet", service_name_systemd],
                    capture_output=True,
                    timeout=5
                )
                is_running = result.returncode == 0
            
            elif check_type == "docker":
                container_name = service_config.get("container_name", service_name)
                result = self._run_command(
                    ["docker", "ps", "--format", "{{.Names}}"],
                    capture_output=True,
                    timeout=5
                )
                is_running = container_name in result.stdout
            
            elif check_type == "port":
                port = service_config.get("port")
                if port:
                    # Usar comando apropriado para a plataforma
                    if PlatformDetector.is_windows():
                        # Windows: netstat
                        result = self._run_command(
                            ["netstat", "-an"],
                            capture_output=True,
                            timeout=5
                        )
                        is_running = f":{port}" in result.stdout and "LISTENING" in result.stdout
                    elif PlatformDetector.is_macos():
                        # macOS: lsof
                        result = self._run_command(
                            ["lsof", "-i", f":{port}"],
                            capture_output=True,
                            timeout=5
                        )
                        is_running = result.returncode == 0
                    else:
                        # Linux: ss
                        result = self._run_command(
                            ["ss", "-lntp"],
                            capture_output=True,
                            timeout=5
                        )
                        is_running = f":{port}" in result.stdout
            
            elif check_type == "http":
                url = service_config.get(
                    "check_url",
                    f"http://localhost:{service_config.get('port', '')}"
                )
                result = self._run_command(
                    ["curl", "-s", "--max-time", "2", url],
                    capture_output=True,
                    timeout=5
                )
                is_running = result.returncode == 0
            
            elif check_type == "process":
                process_name = service_config.get("process_name", service_name)
                # Usar comando apropriado para a plataforma
                if PlatformDetector.is_windows():
                    # Windows: tasklist
                    result = self._run_command(
                        ["tasklist", "/FI", f"IMAGENAME eq {process_name}"],
                        capture_output=True,
                        timeout=5
                    )
                    is_running = process_name.lower() in result.stdout.lower()
                else:
                    # Linux/macOS: pgrep
                    result = self._run_command(
                        ["pgrep", "-f", process_name],
                        capture_output=True,
                        timeout=5
                    )
                    is_running = result.returncode == 0
            
            # Atualizar cache
            if self.cache:
                self.cache.set(f"status:{service_name}", is_running, ttl=self.cache_ttl)
            
            return is_running
        
        except CommandExecutionError as e:
            logger.warning(f"Erro ao verificar status de {service_name}: {e}")
            raise ServiceCheckError(
                f"Erro ao verificar status de {service_name}",
                details=str(e)
            )
    
    def start_service(
        self,
        service_name: str,
        timeout: int = 30,
        wait_for_ready: bool = True
    ) -> bool:
        """
        Inicia um serviço específico.
        
        Args:
            service_name: Nome do serviço
            timeout: Timeout em segundos
            wait_for_ready: Se True, aguarda serviço ficar pronto
            
        Returns:
            True se iniciado com sucesso
            
        Raises:
            ServiceStartError: Se falhar ao iniciar
        """
        ServiceValidator.validate_service_exists(service_name, self.config)
        
        service_config = self.config.get("services", {}).get(service_name, {})
        display_name = service_config.get("display_name", service_name)
        
        # Verificar se já está rodando
        try:
            if self._check_service_running(service_name):
                logger.info(f"{display_name} já está rodando")
                print(fmt.success(f"{display_name} já está rodando"))
                return True
        except ServiceCheckError:
            logger.warning(f"Não foi possível verificar status de {service_name}, tentando iniciar")
        
        logger.info(f"Iniciando {display_name}...")
        print(fmt.progress(f"Iniciando {display_name}..."))
        
        # Invalidar cache
        if self.cache:
            self.cache.invalidate(f"status:{service_name}")
        
        # Tentar script primeiro
        start_script = service_config.get("start_script")
        if start_script:
            script_path = Path(__file__).parent.parent.parent.parent / start_script
            if script_path.exists():
                try:
                    result = self._run_command(
                        ["bash", str(script_path)],
                        capture_output=True,
                        timeout=timeout
                    )
                    if result.returncode == 0:
                        if wait_for_ready:
                            time.sleep(2)
                            if self._check_service_running(service_name, use_cache=False):
                                logger.info(f"{display_name} iniciado com sucesso")
                                print(fmt.success(f"{display_name} iniciado com sucesso"))
                                return True
                            else:
                                logger.warning(f"{display_name} iniciado mas pode não estar acessível")
                                print(fmt.warning(f"{display_name} iniciado mas pode não estar acessível ainda"))
                                return True
                        return True
                except CommandExecutionError as e:
                    logger.error(f"Erro ao executar script: {e}")
        
        # Tentar comando direto
        start_cmd = service_config.get("start_cmd")
        if start_cmd:
            try:
                if isinstance(start_cmd, str):
                    start_cmd = start_cmd.split()
                
                needs_sudo = service_config.get("needs_sudo", False)
                result = self._run_command(
                    start_cmd,
                    capture_output=True,
                    timeout=timeout,
                    needs_sudo=needs_sudo
                )
                
                if result.returncode == 0:
                    if wait_for_ready:
                        time.sleep(2)
                        if self._check_service_running(service_name, use_cache=False):
                            logger.info(f"{display_name} iniciado com sucesso")
                            print(fmt.success(f"{display_name} iniciado com sucesso"))
                            return True
                        else:
                            logger.warning(f"{display_name} iniciado mas pode não estar acessível")
                            print(fmt.warning(f"{display_name} iniciado mas pode não estar acessível ainda"))
                            return True
                    return True
                else:
                    raise ServiceStartError(
                        f"Falha ao iniciar {display_name}",
                        details=result.stderr or "Erro desconhecido"
                    )
            except CommandExecutionError as e:
                raise ServiceStartError(
                    f"Erro ao executar comando para {display_name}",
                    details=str(e)
                )
        
        raise ServiceStartError(
            f"Nenhum método de inicialização configurado para {display_name}"
        )
    
    def stop_service(self, service_name: str, timeout: int = 30) -> bool:
        """
        Para um serviço específico.
        
        Args:
            service_name: Nome do serviço
            timeout: Timeout em segundos
            
        Returns:
            True se parado com sucesso
            
        Raises:
            ServiceStopError: Se falhar ao parar
        """
        ServiceValidator.validate_service_exists(service_name, self.config)
        
        service_config = self.config.get("services", {}).get(service_name, {})
        display_name = service_config.get("display_name", service_name)
        
        # Verificar se está rodando
        try:
            if not self._check_service_running(service_name):
                logger.info(f"{display_name} não está rodando")
                print(fmt.info(f"{display_name} não está rodando"))
                return True
        except ServiceCheckError:
            logger.warning(f"Não foi possível verificar status de {service_name}")
        
        logger.info(f"Parando {display_name}...")
        print(fmt.stop(f"Parando {display_name}..."))
        
        # Invalidar cache
        if self.cache:
            self.cache.invalidate(f"status:{service_name}")
        
        # Tentar script primeiro
        stop_script = service_config.get("stop_script")
        if stop_script:
            script_path = Path(__file__).parent.parent.parent.parent / stop_script
            if script_path.exists():
                try:
                    result = self._run_command(
                        ["bash", str(script_path)],
                        capture_output=True,
                        timeout=timeout
                    )
                    if result.returncode == 0:
                        logger.info(f"{display_name} parado com sucesso")
                        print(fmt.success(f"{display_name} parado com sucesso"))
                        return True
                except CommandExecutionError as e:
                    logger.error(f"Erro ao executar script: {e}")
        
        # Tentar comando direto
        stop_cmd = service_config.get("stop_cmd")
        if stop_cmd:
            try:
                if isinstance(stop_cmd, str):
                    stop_cmd = stop_cmd.split()
                
                needs_sudo = service_config.get("needs_sudo", False)
                result = self._run_command(
                    stop_cmd,
                    capture_output=True,
                    timeout=timeout,
                    needs_sudo=needs_sudo
                )
                
                if result.returncode == 0:
                    logger.info(f"{display_name} parado com sucesso")
                    print(fmt.success(f"{display_name} parado com sucesso"))
                    return True
                else:
                    raise ServiceStopError(
                        f"Falha ao parar {display_name}",
                        details=result.stderr or "Erro desconhecido"
                    )
            except CommandExecutionError as e:
                raise ServiceStopError(
                    f"Erro ao executar comando para {display_name}",
                    details=str(e)
                )
        
        raise ServiceStopError(
            f"Nenhum método de parada configurado para {display_name}"
        )
    
    def get_status(self, service_name: Optional[str] = None) -> Dict[str, Dict[str, Any]]:
        """
        Obtém status de um serviço ou todos os serviços.
        
        Args:
            service_name: Nome do serviço (None = todos)
            
        Returns:
            Dicionário com status dos serviços
        """
        if service_name:
            services = {service_name: self.config.get("services", {}).get(service_name, {})}
        else:
            services = self.config.get("services", {})
        
        status = {}
        for name, config in services.items():
            try:
                is_running = self._check_service_running(name)
            except ServiceCheckError:
                is_running = False
            
            status[name] = {
                "running": is_running,
                "display_name": config.get("display_name", name),
                "description": config.get("description", ""),
                "port": config.get("port"),
                "url": config.get("url")
            }
        
        return status
    
    def start_all(self, exclude: Optional[List[str]] = None) -> Dict[str, bool]:
        """
        Inicia todos os serviços em ordem.
        
        Args:
            exclude: Lista de serviços para excluir
            
        Returns:
            Dicionário com resultado de cada serviço
        """
        exclude = exclude or []
        services = self.config.get("services", {})
        order = self.config.get("start_order", list(services.keys()))
        
        logger.info(f"Iniciando todos os serviços (excluindo: {exclude})")
        print(fmt.progress("Iniciando todos os serviços...\n"))
        
        results = {}
        for service_name in order:
            if service_name in exclude:
                logger.info(f"Pulando {service_name} (excluído)")
                print(fmt.info(f"Pulando {service_name} (excluído)"))
                continue
            
            if service_name not in services:
                continue
            
            try:
                results[service_name] = self.start_service(service_name)
            except Exception as e:
                logger.error(f"Erro ao iniciar {service_name}: {e}")
                print(fmt.error(f"Erro ao iniciar {service_name}: {e}"))
                results[service_name] = False
            
            print()  # Linha em branco entre serviços
        
        return results
    
    def stop_all(self, exclude: Optional[List[str]] = None) -> Dict[str, bool]:
        """
        Para todos os serviços em ordem reversa.
        
        Args:
            exclude: Lista de serviços para excluir
            
        Returns:
            Dicionário com resultado de cada serviço
        """
        exclude = exclude or []
        services = self.config.get("services", {})
        order = list(reversed(self.config.get("start_order", list(services.keys()))))
        
        logger.info(f"Parando todos os serviços (excluindo: {exclude})")
        print(fmt.stop("Parando todos os serviços...\n"))
        
        results = {}
        for service_name in order:
            if service_name in exclude:
                logger.info(f"Pulando {service_name} (excluído)")
                print(fmt.info(f"Pulando {service_name} (excluído)"))
                continue
            
            if service_name not in services:
                continue
            
            try:
                results[service_name] = self.stop_service(service_name)
            except Exception as e:
                logger.error(f"Erro ao parar {service_name}: {e}")
                print(fmt.error(f"Erro ao parar {service_name}: {e}"))
                results[service_name] = False
            
            print()  # Linha em branco entre serviços
        
        return results
