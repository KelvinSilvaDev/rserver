"""
Sistema de cache para otimização de performance
"""

import time
from typing import Any, Dict, Optional
from threading import Lock
from dataclasses import dataclass, field


@dataclass
class CacheEntry:
    """Entrada de cache com TTL"""
    value: Any
    timestamp: float = field(default_factory=time.time)
    ttl: float = 5.0  # Time to live em segundos
    
    def is_expired(self) -> bool:
        """Verifica se a entrada expirou"""
        return time.time() - self.timestamp > self.ttl


class CacheManager:
    """
    Gerenciador de cache thread-safe com TTL.
    
    Usado para cachear resultados de verificações de status,
    configurações, e outros dados que não mudam frequentemente.
    """
    
    def __init__(self):
        self._cache: Dict[str, CacheEntry] = {}
        self._lock = Lock()
    
    def get(self, key: str) -> Optional[Any]:
        """
        Obtém valor do cache se não expirou.
        
        Args:
            key: Chave do cache
            
        Returns:
            Valor cacheado ou None se não existe ou expirou
        """
        with self._lock:
            entry = self._cache.get(key)
            if entry is None:
                return None
            
            if entry.is_expired():
                del self._cache[key]
                return None
            
            return entry.value
    
    def set(self, key: str, value: Any, ttl: float = 5.0) -> None:
        """
        Armazena valor no cache com TTL.
        
        Args:
            key: Chave do cache
            value: Valor a armazenar
            ttl: Time to live em segundos
        """
        with self._lock:
            self._cache[key] = CacheEntry(value=value, ttl=ttl)
    
    def invalidate(self, key: str) -> None:
        """
        Remove entrada do cache.
        
        Args:
            key: Chave a remover
        """
        with self._lock:
            self._cache.pop(key, None)
    
    def clear(self) -> None:
        """Limpa todo o cache"""
        with self._lock:
            self._cache.clear()
    
    def cleanup_expired(self) -> int:
        """
        Remove entradas expiradas do cache.
        
        Returns:
            Número de entradas removidas
        """
        with self._lock:
            expired_keys = [
                key for key, entry in self._cache.items()
                if entry.is_expired()
            ]
            for key in expired_keys:
                del self._cache[key]
            return len(expired_keys)
