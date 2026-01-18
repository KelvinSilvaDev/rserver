"""
Configuração de testes (pytest fixtures)
"""

import pytest
from pathlib import Path
from unittest.mock import Mock, MagicMock
import json
import tempfile

# Adicionar src ao path
import sys
src_path = Path(__file__).parent.parent / "src"
sys.path.insert(0, str(src_path))


@pytest.fixture
def temp_config_file():
    """Cria arquivo de configuração temporário"""
    config = {
        "start_order": ["ssh", "ollama"],
        "services": {
            "ssh": {
                "display_name": "SSH Server",
                "description": "Servidor SSH",
                "port": 22,
                "check_type": "systemd",
                "needs_sudo": True,
                "start_cmd": ["service", "ssh", "start"],
                "stop_cmd": ["service", "ssh", "stop"]
            },
            "ollama": {
                "display_name": "Ollama",
                "description": "Servidor de IA",
                "port": 11434,
                "check_type": "http",
                "check_url": "http://localhost:11434/api/tags",
                "needs_sudo": True,
                "start_cmd": ["systemctl", "start", "ollama"],
                "stop_cmd": ["systemctl", "stop", "ollama"]
            }
        }
    }
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(config, f)
        temp_path = Path(f.name)
    
    yield temp_path
    
    # Cleanup
    if temp_path.exists():
        temp_path.unlink()


@pytest.fixture
def mock_subprocess_run(monkeypatch):
    """Mock para subprocess.run"""
    def mock_run(cmd, **kwargs):
        result = Mock()
        result.returncode = 0
        result.stdout = ""
        result.stderr = ""
        return result
    
    monkeypatch.setattr("subprocess.run", mock_run)
    return mock_run


@pytest.fixture
def mock_logger(monkeypatch):
    """Mock para logger"""
    logger = MagicMock()
    monkeypatch.setattr("src.utils.logger.get_logger", lambda name: logger)
    return logger
