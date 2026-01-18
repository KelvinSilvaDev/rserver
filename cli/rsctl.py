#!/usr/bin/env python3
"""
Remote Server Control (rserver) - CLI legado para gerenciar serviços do servidor remoto
"""

import argparse
import json
import subprocess
import sys
import os
from pathlib import Path
from typing import Dict, List, Optional
import time

# Cores para output
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

# Diretório base do projeto
BASE_DIR = Path(__file__).parent.parent
CONFIG_FILE = BASE_DIR / "cli" / "services.json"
LOGS_DIR = BASE_DIR / "logs"


class ServiceManager:
    """Gerenciador de serviços do servidor remoto"""
    
    def __init__(self):
        self.config = self._load_config()
        self.logs_dir = LOGS_DIR
        self.logs_dir.mkdir(exist_ok=True)
    
    def _load_config(self) -> Dict:
        """Carrega configuração dos serviços"""
        if CONFIG_FILE.exists():
            with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}
    
    def _run_command(self, cmd: List[str], check: bool = False, capture_output: bool = False) -> subprocess.CompletedProcess:
        """Executa comando shell"""
        try:
            result = subprocess.run(
                cmd,
                check=check,
                capture_output=capture_output,
                text=True
            )
            return result
        except subprocess.CalledProcessError as e:
            if not capture_output:
                print(f"{RED}❌ Erro ao executar: {' '.join(cmd)}{NC}")
            raise
    
    def _check_service_running(self, service_name: str) -> bool:
        """Verifica se um serviço está rodando"""
        service_config = self.config.get("services", {}).get(service_name, {})
        check_type = service_config.get("check_type", "process")
        
        if check_type == "systemd":
            result = self._run_command(
                ["systemctl", "is-active", "--quiet", service_name],
                capture_output=True
            )
            return result.returncode == 0
        
        elif check_type == "docker":
            container_name = service_config.get("container_name", service_name)
            result = self._run_command(
                ["docker", "ps", "--format", "{{.Names}}"],
                capture_output=True
            )
            return container_name in result.stdout
        
        elif check_type == "port":
            port = service_config.get("port")
            if port:
                result = self._run_command(
                    ["ss", "-lntp"],
                    capture_output=True
                )
                return f":{port}" in result.stdout
            return False
        
        elif check_type == "http":
            url = service_config.get("check_url", f"http://localhost:{service_config.get('port', '')}")
            result = self._run_command(
                ["curl", "-s", "--max-time", "2", url],
                capture_output=True
            )
            return result.returncode == 0
        
        elif check_type == "process":
            process_name = service_config.get("process_name", service_name)
            result = self._run_command(
                ["pgrep", "-f", process_name],
                capture_output=True
            )
            return result.returncode == 0
        
        return False
    
    def start_service(self, service_name: str) -> bool:
        """Inicia um serviço específico"""
        if service_name not in self.config.get("services", {}):
            print(f"{RED}❌ Serviço '{service_name}' não encontrado na configuração{NC}")
            return False
        
        service_config = self.config.get("services", {}).get(service_name, {})
        display_name = service_config.get("display_name", service_name)
        
        # Verificar se já está rodando
        if self._check_service_running(service_name):
            print(f"{GREEN}✅ {display_name} já está rodando{NC}")
            return True
        
        print(f"{YELLOW}🚀 Iniciando {display_name}...{NC}")
        
        # Executar script de inicialização
        start_script = service_config.get("start_script")
        if start_script:
            script_path = BASE_DIR / start_script
            if script_path.exists():
                try:
                    result = self._run_command(
                        ["bash", str(script_path)],
                        capture_output=True
                    )
                    if result.returncode == 0:
                        # Aguardar um pouco e verificar
                        time.sleep(2)
                        if self._check_service_running(service_name):
                            print(f"{GREEN}✅ {display_name} iniciado com sucesso{NC}")
                            return True
                        else:
                            print(f"{YELLOW}⚠️  {display_name} iniciado mas pode não estar acessível ainda{NC}")
                            return True
                    else:
                        print(f"{RED}❌ Erro ao iniciar {display_name}{NC}")
                        return False
                except Exception as e:
                    print(f"{RED}❌ Erro ao executar script: {e}{NC}")
                    return False
        
        # Executar comando direto
        start_cmd = service_config.get("start_cmd")
        if start_cmd:
            try:
                if isinstance(start_cmd, str):
                    start_cmd = start_cmd.split()
                
                # Verificar se precisa de sudo
                needs_sudo = service_config.get("needs_sudo", False)
                if needs_sudo:
                    start_cmd = ["sudo"] + start_cmd
                
                result = self._run_command(start_cmd, capture_output=True)
                if result.returncode == 0:
                    time.sleep(2)
                    if self._check_service_running(service_name):
                        print(f"{GREEN}✅ {display_name} iniciado com sucesso{NC}")
                        return True
                    else:
                        print(f"{YELLOW}⚠️  {display_name} iniciado mas pode não estar acessível ainda{NC}")
                        return True
                else:
                    print(f"{RED}❌ Erro ao iniciar {display_name}{NC}")
                    if result.stderr:
                        print(f"{RED}   {result.stderr}{NC}")
                    return False
            except Exception as e:
                print(f"{RED}❌ Erro ao executar comando: {e}{NC}")
                return False
        
        print(f"{RED}❌ Nenhum método de inicialização configurado para {display_name}{NC}")
        return False
    
    def stop_service(self, service_name: str) -> bool:
        """Para um serviço específico"""
        if service_name not in self.config.get("services", {}):
            print(f"{RED}❌ Serviço '{service_name}' não encontrado na configuração{NC}")
            return False
        
        service_config = self.config.get("services", {}).get(service_name, {})
        display_name = service_config.get("display_name", service_name)
        
        # Verificar se está rodando
        if not self._check_service_running(service_name):
            print(f"{YELLOW}ℹ️  {display_name} não está rodando{NC}")
            return True
        
        print(f"{YELLOW}🛑 Parando {display_name}...{NC}")
        
        # Executar script de parada
        stop_script = service_config.get("stop_script")
        if stop_script:
            script_path = BASE_DIR / stop_script
            if script_path.exists():
                try:
                    result = self._run_command(
                        ["bash", str(script_path)],
                        capture_output=True
                    )
                    if result.returncode == 0:
                        print(f"{GREEN}✅ {display_name} parado com sucesso{NC}")
                        return True
                except Exception as e:
                    print(f"{RED}❌ Erro ao executar script: {e}{NC}")
        
        # Executar comando direto
        stop_cmd = service_config.get("stop_cmd")
        if stop_cmd:
            try:
                if isinstance(stop_cmd, str):
                    stop_cmd = stop_cmd.split()
                
                needs_sudo = service_config.get("needs_sudo", False)
                if needs_sudo:
                    stop_cmd = ["sudo"] + stop_cmd
                
                result = self._run_command(stop_cmd, capture_output=True)
                if result.returncode == 0:
                    print(f"{GREEN}✅ {display_name} parado com sucesso{NC}")
                    return True
            except Exception as e:
                print(f"{RED}❌ Erro ao executar comando: {e}{NC}")
        
        print(f"{RED}❌ Nenhum método de parada configurado para {display_name}{NC}")
        return False
    
    def get_status(self, service_name: Optional[str] = None) -> Dict:
        """Obtém status de um serviço ou todos os serviços"""
        if service_name:
            if service_name not in self.config.get("services", {}):
                return {}
            services = {service_name: self.config.get("services", {}).get(service_name, {})}
        else:
            services = self.config.get("services", {})
        
        status = {}
        for name, config in services.items():
            is_running = self._check_service_running(name)
            status[name] = {
                "running": is_running,
                "display_name": config.get("display_name", name),
                "description": config.get("description", ""),
                "port": config.get("port"),
                "url": config.get("url")
            }
        
        return status
    
    def list_services(self):
        """Lista todos os serviços disponíveis"""
        services = self.config.get("services", {})
        if not services:
            print(f"{YELLOW}⚠️  Nenhum serviço configurado{NC}")
            return
        
        print(f"{BLUE}📋 Serviços disponíveis:{NC}\n")
        for name, config in services.items():
            display_name = config.get("display_name", name)
            description = config.get("description", "")
            is_running = self._check_service_running(name)
            status_icon = f"{GREEN}●{NC}" if is_running else f"{RED}○{NC}"
            print(f"  {status_icon} {display_name} ({name})")
            if description:
                print(f"     {description}")
            if config.get("port"):
                print(f"     Porta: {config.get('port')}")
            print()
    
    def start_all(self, exclude: List[str] = None):
        """Inicia todos os serviços"""
        exclude = exclude or []
        services = self.config.get("services", {})
        
        # Ordenar por dependências
        ordered_services = self._order_by_dependencies(services)
        
        print(f"{BLUE}🚀 Iniciando todos os serviços...{NC}\n")
        
        for service_name in ordered_services:
            if service_name in exclude:
                print(f"{YELLOW}⏭️  Pulando {service_name} (excluído){NC}")
                continue
            
            self.start_service(service_name)
            print()
    
    def stop_all(self, exclude: List[str] = None):
        """Para todos os serviços"""
        exclude = exclude or []
        services = self.config.get("services", {})
        
        # Ordenar por dependências (reverso para parar)
        ordered_services = list(reversed(self._order_by_dependencies(services)))
        
        print(f"{BLUE}🛑 Parando todos os serviços...{NC}\n")
        
        for service_name in ordered_services:
            if service_name in exclude:
                print(f"{YELLOW}⏭️  Pulando {service_name} (excluído){NC}")
                continue
            
            self.stop_service(service_name)
            print()
    
    def _order_by_dependencies(self, services: Dict) -> List[str]:
        """Ordena serviços por dependências"""
        # Implementação simples: retorna ordem definida na config
        order = self.config.get("start_order", list(services.keys()))
        return [s for s in order if s in services]
    
    def show_status(self, service_name: Optional[str] = None):
        """Mostra status formatado"""
        status = self.get_status(service_name)
        
        if not status:
            print(f"{YELLOW}⚠️  Nenhum serviço encontrado{NC}")
            return
        
        print(f"{BLUE}📊 Status dos Serviços{NC}\n")
        print("=" * 60)
        
        for name, info in status.items():
            status_icon = f"{GREEN}● RODANDO{NC}" if info["running"] else f"{RED}○ PARADO{NC}"
            print(f"\n{status_icon} {info['display_name']}")
            if info["description"]:
                print(f"   {info['description']}")
            if info["port"]:
                print(f"   Porta: {info['port']}")
            if info["url"]:
                print(f"   URL: {info['url']}")
        
        print("\n" + "=" * 60)


def main():
    parser = argparse.ArgumentParser(
        description="Remote Server Control - Gerencia serviços do servidor remoto",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  rserver start all                    # Inicia todos os serviços
  rserver start ssh ollama             # Inicia apenas SSH e Ollama
  rserver stop webui                   # Para o Web-UI
  rserver status                       # Mostra status de todos os serviços
  rserver status ollama                # Mostra status do Ollama
  rserver list                         # Lista serviços disponíveis
        """
    )
    
    subparsers = parser.add_subparsers(dest="command", help="Comando a executar")
    
    # Comando start
    start_parser = subparsers.add_parser("start", help="Inicia serviços")
    start_parser.add_argument(
        "services",
        nargs="+",
        help="Serviços para iniciar (use 'all' para todos)"
    )
    start_parser.add_argument(
        "--exclude",
        nargs="+",
        default=[],
        help="Serviços para excluir ao iniciar todos"
    )
    
    # Comando stop
    stop_parser = subparsers.add_parser("stop", help="Para serviços")
    stop_parser.add_argument(
        "services",
        nargs="+",
        help="Serviços para parar (use 'all' para todos)"
    )
    stop_parser.add_argument(
        "--exclude",
        nargs="+",
        default=[],
        help="Serviços para excluir ao parar todos"
    )
    
    # Comando status
    status_parser = subparsers.add_parser("status", help="Mostra status dos serviços")
    status_parser.add_argument(
        "service",
        nargs="?",
        help="Serviço específico (opcional)"
    )
    
    # Comando list
    subparsers.add_parser("list", help="Lista serviços disponíveis")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    manager = ServiceManager()
    
    try:
        if args.command == "start":
            if "all" in args.services:
                manager.start_all(exclude=args.exclude)
            else:
                for service in args.services:
                    manager.start_service(service)
                    print()
        
        elif args.command == "stop":
            if "all" in args.services:
                manager.stop_all(exclude=args.exclude)
            else:
                for service in args.services:
                    manager.stop_service(service)
                    print()
        
        elif args.command == "status":
            manager.show_status(args.service)
        
        elif args.command == "list":
            manager.list_services()
    
    except KeyboardInterrupt:
        print(f"\n{YELLOW}⚠️  Operação cancelada pelo usuário{NC}")
        sys.exit(1)
    except Exception as e:
        print(f"{RED}❌ Erro: {e}{NC}")
        sys.exit(1)


if __name__ == "__main__":
    main()
