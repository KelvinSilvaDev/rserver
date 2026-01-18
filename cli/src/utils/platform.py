"""
Utilitários para detecção e compatibilidade multiplataforma
"""

import platform
import sys
from typing import Optional, Tuple
from pathlib import Path


class PlatformDetector:
    """Detecta e fornece informações sobre a plataforma atual"""
    
    @staticmethod
    def get_platform() -> str:
        """
        Retorna o nome da plataforma.
        
        Returns:
            'linux', 'windows', 'darwin' (macOS), ou 'unknown'
        """
        system = platform.system().lower()
        if system == 'linux':
            return 'linux'
        elif system == 'windows':
            return 'windows'
        elif system == 'darwin':
            return 'darwin'
        else:
            return 'unknown'
    
    @staticmethod
    def is_linux() -> bool:
        """Verifica se está rodando em Linux"""
        return PlatformDetector.get_platform() == 'linux'
    
    @staticmethod
    def is_windows() -> bool:
        """Verifica se está rodando em Windows"""
        return PlatformDetector.get_platform() == 'windows'
    
    @staticmethod
    def is_macos() -> bool:
        """Verifica se está rodando em macOS"""
        return PlatformDetector.get_platform() == 'darwin'
    
    @staticmethod
    def is_unix_like() -> bool:
        """Verifica se está rodando em sistema Unix-like (Linux, macOS)"""
        return PlatformDetector.is_linux() or PlatformDetector.is_macos()
    
    @staticmethod
    def get_install_dir() -> Path:
        """
        Retorna diretório de instalação apropriado para a plataforma.
        
        Returns:
            Path do diretório de instalação
        """
        platform_name = PlatformDetector.get_platform()
        
        if platform_name == 'windows':
            # Windows: usar AppData\Local\Programs ou Python Scripts
            if sys.executable:
                # Tentar usar Scripts do Python
                python_dir = Path(sys.executable).parent
                scripts_dir = python_dir / 'Scripts'
                if scripts_dir.exists():
                    return scripts_dir
            # Fallback: AppData Local
            return Path.home() / 'AppData' / 'Local' / 'Programs' / 'rserver'
        elif platform_name == 'darwin':
            # macOS: /usr/local/bin ou ~/.local/bin
            return Path('/usr/local/bin')
        else:
            # Linux: /usr/local/bin ou ~/.local/bin
            return Path('/usr/local/bin')
    
    @staticmethod
    def get_user_install_dir() -> Path:
        """
        Retorna diretório de instalação do usuário (sem sudo).
        
        Returns:
            Path do diretório de instalação do usuário
        """
        platform_name = PlatformDetector.get_platform()
        
        if platform_name == 'windows':
            return Path.home() / 'AppData' / 'Local' / 'Programs' / 'rserver'
        else:
            # Unix-like: ~/.local/bin
            return Path.home() / '.local' / 'bin'
    
    @staticmethod
    def needs_sudo() -> bool:
        """
        Verifica se precisa de sudo para instalação global.
        
        Returns:
            True se precisa sudo (Linux/macOS com /usr/local/bin)
        """
        if PlatformDetector.is_windows():
            return False
        install_dir = PlatformDetector.get_install_dir()
        return str(install_dir).startswith('/usr')
    
    @staticmethod
    def get_shell_config_file() -> Optional[Path]:
        """
        Retorna arquivo de configuração do shell.
        
        Returns:
            Path do arquivo de configuração ou None
        """
        platform_name = PlatformDetector.get_platform()
        
        if platform_name == 'windows':
            # Windows: PowerShell profile
            return Path.home() / 'Documents' / 'PowerShell' / 'Microsoft.PowerShell_profile.ps1'
        else:
            # Unix-like: detectar shell
            shell = Path(os.environ.get('SHELL', '/bin/bash')).name
            if shell == 'zsh':
                return Path.home() / '.zshrc'
            else:
                return Path.home() / '.bashrc'
    
    @staticmethod
    def get_command_separator() -> str:
        """
        Retorna separador de comandos para a plataforma.
        
        Returns:
            ';' para Windows, '&&' para Unix-like
        """
        if PlatformDetector.is_windows():
            return ';'
        else:
            return '&&'
    
    @staticmethod
    def get_sudo_command() -> Optional[str]:
        """
        Retorna comando sudo apropriado (ou None se não necessário).
        
        Returns:
            'sudo' para Unix-like, None para Windows
        """
        if PlatformDetector.is_windows():
            return None
        else:
            return 'sudo'
    
    @staticmethod
    def format_path(path: Path) -> str:
        """
        Formata path de forma apropriada para a plataforma.
        
        Args:
            path: Path a formatar
            
        Returns:
            String formatada
        """
        if PlatformDetector.is_windows():
            return str(path).replace('/', '\\')
        else:
            return str(path)


import os
