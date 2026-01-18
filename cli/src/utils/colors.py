"""
Utilitários para cores e formatação no terminal
"""

import sys
from typing import Optional


class Colors:
    """Cores ANSI para terminal"""
    RESET = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    
    # Cores básicas
    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'
    
    # Cores brilhantes
    BRIGHT_BLACK = '\033[90m'
    BRIGHT_RED = '\033[91m'
    BRIGHT_GREEN = '\033[92m'
    BRIGHT_YELLOW = '\033[93m'
    BRIGHT_BLUE = '\033[94m'
    BRIGHT_MAGENTA = '\033[95m'
    BRIGHT_CYAN = '\033[96m'
    BRIGHT_WHITE = '\033[97m'
    
    # Background
    BG_RED = '\033[41m'
    BG_GREEN = '\033[42m'
    BG_YELLOW = '\033[43m'
    BG_BLUE = '\033[44m'


class Formatter:
    """Formatador de texto para terminal"""
    
    @staticmethod
    def success(text: str) -> str:
        """Texto de sucesso (verde)"""
        return f"{Colors.GREEN}✅ {text}{Colors.RESET}"
    
    @staticmethod
    def error(text: str) -> str:
        """Texto de erro (vermelho)"""
        return f"{Colors.RED}❌ {text}{Colors.RESET}"
    
    @staticmethod
    def warning(text: str) -> str:
        """Texto de aviso (amarelo)"""
        return f"{Colors.YELLOW}⚠️  {text}{Colors.RESET}"
    
    @staticmethod
    def info(text: str) -> str:
        """Texto informativo (azul)"""
        return f"{Colors.BLUE}ℹ️  {text}{Colors.RESET}"
    
    @staticmethod
    def progress(text: str) -> str:
        """Texto de progresso (ciano)"""
        return f"{Colors.CYAN}🚀 {text}{Colors.RESET}"
    
    @staticmethod
    def stop(text: str) -> str:
        """Texto de parada (amarelo)"""
        return f"{Colors.YELLOW}🛑 {text}{Colors.RESET}"
    
    @staticmethod
    def bold(text: str) -> str:
        """Texto em negrito"""
        return f"{Colors.BOLD}{text}{Colors.RESET}"
    
    @staticmethod
    def dim(text: str) -> str:
        """Texto atenuado"""
        return f"{Colors.DIM}{text}{Colors.RESET}"
    
    @staticmethod
    def status_running(text: str) -> str:
        """Status: rodando (verde)"""
        return f"{Colors.GREEN}●{Colors.RESET} {text}"
    
    @staticmethod
    def status_stopped(text: str) -> str:
        """Status: parado (vermelho)"""
        return f"{Colors.RED}○{Colors.RESET} {text}"


def supports_color() -> bool:
    """Verifica se o terminal suporta cores"""
    import os
    return (
        hasattr(sys.stdout, 'isatty') and sys.stdout.isatty() or
        os.getenv('TERM') != 'dumb' or
        os.getenv('COLORTERM') is not None
    )


# Instância global do formatador
fmt = Formatter()
