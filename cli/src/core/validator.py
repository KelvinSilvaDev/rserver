"""
Validações para configuração e operações
"""

import json
from pathlib import Path
from typing import Dict, List, Any, Optional
import subprocess

from ..utils.exceptions import (
    ConfigError,
    DependencyError,
    ServiceNotFoundError,
)


class ConfigValidator:
    """Valida configuração de serviços"""
    
    REQUIRED_SERVICE_KEYS = ['display_name', 'check_type']
    VALID_CHECK_TYPES = ['systemd', 'docker', 'port', 'http', 'process']
    
    @staticmethod
    def validate_config(config: Dict[str, Any]) -> None:
        """
        Valida estrutura da configuração.
        
        Args:
            config: Dicionário de configuração
            
        Raises:
            ConfigError: Se a configuração for inválida
        """
        if not isinstance(config, dict):
            raise ConfigError("Configuração deve ser um dicionário")
        
        if 'services' not in config:
            raise ConfigError("Configuração deve ter chave 'services'")
        
        services = config.get('services', {})
        if not isinstance(services, dict):
            raise ConfigError("'services' deve ser um dicionário")
        
        if not services:
            raise ConfigError("Nenhum serviço configurado")
        
        # Validar cada serviço
        for service_name, service_config in services.items():
            ConfigValidator.validate_service(service_name, service_config)
    
    @staticmethod
    def validate_service(service_name: str, service_config: Dict[str, Any]) -> None:
        """
        Valida configuração de um serviço específico.
        
        Args:
            service_name: Nome do serviço
            service_config: Configuração do serviço
            
        Raises:
            ConfigError: Se a configuração for inválida
        """
        if not isinstance(service_config, dict):
            raise ConfigError(f"Configuração do serviço '{service_name}' deve ser um dicionário")
        
        # Verificar campos obrigatórios
        for key in ConfigValidator.REQUIRED_SERVICE_KEYS:
            if key not in service_config:
                raise ConfigError(
                    f"Serviço '{service_name}' deve ter campo '{key}'"
                )
        
        # Validar check_type
        check_type = service_config.get('check_type')
        if check_type not in ConfigValidator.VALID_CHECK_TYPES:
            raise ConfigError(
                f"check_type '{check_type}' inválido para serviço '{service_name}'. "
                f"Valores válidos: {', '.join(ConfigValidator.VALID_CHECK_TYPES)}"
            )
        
        # Validações específicas por tipo
        if check_type == 'docker':
            if 'container_name' not in service_config:
                raise ConfigError(
                    f"Serviço '{service_name}' com check_type 'docker' deve ter 'container_name'"
                )
        
        if check_type == 'http':
            if 'check_url' not in service_config and 'port' not in service_config:
                raise ConfigError(
                    f"Serviço '{service_name}' com check_type 'http' deve ter 'check_url' ou 'port'"
                )
        
        if check_type == 'port':
            if 'port' not in service_config:
                raise ConfigError(
                    f"Serviço '{service_name}' com check_type 'port' deve ter 'port'"
                )
        
        if check_type == 'process':
            if 'process_name' not in service_config:
                raise ConfigError(
                    f"Serviço '{service_name}' com check_type 'process' deve ter 'process_name'"
                )


class DependencyChecker:
    """Verifica dependências do sistema"""
    
    REQUIRED_COMMANDS = {
        'docker': ['docker', '--version'],
        'systemctl': ['systemctl', '--version'],
        'curl': ['curl', '--version'],
        'ss': ['ss', '--version'],
        'pgrep': ['pgrep', '--version'],
    }
    
    @staticmethod
    def check_command(command: str) -> bool:
        """
        Verifica se um comando está disponível.
        
        Args:
            command: Nome do comando
            
        Returns:
            True se o comando está disponível
        """
        try:
            result = subprocess.run(
                ['which', command],
                capture_output=True,
                timeout=2
            )
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False
    
    @staticmethod
    def check_dependencies(required: Optional[List[str]] = None) -> Dict[str, bool]:
        """
        Verifica dependências necessárias.
        
        Args:
            required: Lista de comandos a verificar (None = todos)
            
        Returns:
            Dicionário com status de cada dependência
        """
        if required is None:
            required = list(DependencyChecker.REQUIRED_COMMANDS.keys())
        
        status = {}
        for cmd in required:
            status[cmd] = DependencyChecker.check_command(cmd)
        
        return status
    
    @staticmethod
    def ensure_dependencies(required: List[str]) -> None:
        """
        Garante que dependências estão disponíveis.
        
        Args:
            required: Lista de comandos necessários
            
        Raises:
            DependencyError: Se alguma dependência não estiver disponível
        """
        missing = []
        for cmd in required:
            if not DependencyChecker.check_command(cmd):
                missing.append(cmd)
        
        if missing:
            raise DependencyError(
                f"Dependências não encontradas: {', '.join(missing)}. "
                f"Instale-as antes de continuar."
            )


class ServiceValidator:
    """Valida serviços e operações"""
    
    @staticmethod
    def validate_service_exists(service_name: str, config: Dict[str, Any]) -> None:
        """
        Valida se serviço existe na configuração.
        
        Args:
            service_name: Nome do serviço
            config: Configuração completa
            
        Raises:
            ServiceNotFoundError: Se o serviço não existir
        """
        services = config.get('services', {})
        if service_name not in services:
            available = ', '.join(services.keys())
            raise ServiceNotFoundError(
                f"Serviço '{service_name}' não encontrado. "
                f"Serviços disponíveis: {available}"
            )
