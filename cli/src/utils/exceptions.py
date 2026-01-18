"""
Exceções customizadas para rserver
"""


class RSCTLError(Exception):
    """Base exception para todas as exceções do rserver"""
    
    def __init__(self, message: str, details: str = None):
        super().__init__(message)
        self.message = message
        self.details = details
    
    def __str__(self) -> str:
        if self.details:
            return f"{self.message}: {self.details}"
        return self.message


class ConfigError(RSCTLError):
    """Erro relacionado à configuração"""
    pass


class ServiceNotFoundError(RSCTLError):
    """Serviço não encontrado na configuração"""
    pass


class ServiceStartError(RSCTLError):
    """Erro ao iniciar serviço"""
    pass


class ServiceStopError(RSCTLError):
    """Erro ao parar serviço"""
    pass


class ServiceCheckError(RSCTLError):
    """Erro ao verificar status do serviço"""
    pass


class CommandExecutionError(RSCTLError):
    """Erro ao executar comando"""
    
    def __init__(self, message: str, command: str = None, exit_code: int = None):
        super().__init__(message)
        self.command = command
        self.exit_code = exit_code


class DependencyError(RSCTLError):
    """Erro de dependência (ferramenta/comando não encontrado)"""
    pass


class PermissionError(RSCTLError):
    """Erro de permissão"""
    pass
