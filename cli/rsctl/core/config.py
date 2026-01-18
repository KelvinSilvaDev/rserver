"""
Gerenciamento de configuração
"""

import json
from pathlib import Path
from typing import Dict, Any, Optional
import sys

from ..utils.exceptions import ConfigError
from .validator import ConfigValidator

# Tentar importar importlib.resources (Python 3.9+)
try:
    from importlib.resources import files, as_file
    HAS_RESOURCES = True
except ImportError:
    # Fallback para Python 3.7/3.8
    try:
        from importlib_resources import files, as_file
        HAS_RESOURCES = True
    except ImportError:
        HAS_RESOURCES = False


class ConfigManager:
    """
    Gerencia carregamento e validação de configuração.
    """
    
    def __init__(self, config_path: Optional[Path] = None):
        """
        Inicializa gerenciador de configuração.
        
        Args:
            config_path: Caminho para arquivo de configuração
        """
        self.config_path = config_path or self._default_config_path()
        self._config: Optional[Dict[str, Any]] = None
    
    @staticmethod
    def _default_config_path() -> Path:
        """Retorna caminho padrão da configuração"""
        # Primeiro, tentar encontrar no pacote instalado
        if HAS_RESOURCES:
            try:
                # Tentar carregar do pacote
                package = files('rsctl')
                config_file = package / 'services.json'
                if config_file.exists():
                    # Retornar caminho absoluto do arquivo no pacote
                    with as_file(config_file) as path:
                        return Path(path)
            except (ModuleNotFoundError, FileNotFoundError, TypeError):
                pass
        
        # Fallback: procurar no diretório de desenvolvimento
        # Caminho relativo ao arquivo atual (rsctl/core/config.py)
        # Subir 3 níveis: rsctl/core -> rsctl -> cli -> raiz
        base_dir = Path(__file__).parent.parent.parent
        dev_path = base_dir / "services.json"
        if dev_path.exists():
            return dev_path
        
        # Se não encontrar, retornar caminho padrão do sistema
        # Linux/macOS: ~/.config/rserver/services.json
        # Windows: %APPDATA%/rserver/services.json
        import platform
        if platform.system() == "Windows":
            config_dir = Path.home() / "AppData" / "Roaming" / "rserver"
        else:
            config_dir = Path.home() / ".config" / "rserver"
        
        config_dir.mkdir(parents=True, exist_ok=True)
        return config_dir / "services.json"
    
    def load(self, validate: bool = True) -> Dict[str, Any]:
        """
        Carrega configuração do arquivo.
        
        Args:
            validate: Se True, valida a configuração após carregar
            
        Returns:
            Dicionário de configuração
            
        Raises:
            ConfigError: Se arquivo não existir ou for inválido
        """
        if self._config is not None:
            return self._config
        
        if not self.config_path.exists():
            raise ConfigError(
                f"Arquivo de configuração não encontrado: {self.config_path}"
            )
        
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
        except json.JSONDecodeError as e:
            raise ConfigError(
                f"Erro ao parsear JSON: {e}",
                details=f"Arquivo: {self.config_path}"
            )
        except Exception as e:
            raise ConfigError(
                f"Erro ao carregar configuração: {e}",
                details=f"Arquivo: {self.config_path}"
            )
        
        if validate:
            ConfigValidator.validate_config(config)
        
        self._config = config
        return config
    
    def reload(self) -> Dict[str, Any]:
        """
        Recarrega configuração do arquivo.
        
        Returns:
            Dicionário de configuração atualizado
        """
        self._config = None
        return self.load()
    
    def get(self, key: str, default: Any = None) -> Any:
        """
        Obtém valor da configuração.
        
        Args:
            key: Chave (suporta notação de ponto, ex: 'services.ssh')
            default: Valor padrão se não encontrado
            
        Returns:
            Valor da configuração ou default
        """
        if self._config is None:
            self.load()
        
        keys = key.split('.')
        value = self._config
        
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
                if value is None:
                    return default
            else:
                return default
        
        return value
    
    @property
    def config(self) -> Dict[str, Any]:
        """Acesso direto à configuração"""
        if self._config is None:
            self.load()
        return self._config
