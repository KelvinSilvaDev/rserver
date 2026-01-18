"""
Utilitários para rserver
"""

from .exceptions import (
    RSCTLError,
    ConfigError,
    ServiceNotFoundError,
    ServiceStartError,
    ServiceStopError,
    ServiceCheckError,
    CommandExecutionError,
    DependencyError,
    PermissionError,
)
from .logger import setup_logger, get_logger
from .colors import Colors, Formatter, fmt, supports_color
from .platform import PlatformDetector

__all__ = [
    'RSCTLError',
    'ConfigError',
    'ServiceNotFoundError',
    'ServiceStartError',
    'ServiceStopError',
    'ServiceCheckError',
    'CommandExecutionError',
    'DependencyError',
    'PermissionError',
    'setup_logger',
    'get_logger',
    'Colors',
    'Formatter',
    'fmt',
    'supports_color',
    'PlatformDetector',
]
