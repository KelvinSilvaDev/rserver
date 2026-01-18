"""
Testes unitários para CacheManager
"""

import pytest
import time
from src.core.cache import CacheManager, CacheEntry


class TestCacheEntry:
    """Testes para CacheEntry"""
    
    def test_cache_entry_not_expired(self):
        """Testa que entrada não expirada retorna False"""
        entry = CacheEntry(value="test", ttl=10.0)
        assert not entry.is_expired()
    
    def test_cache_entry_expired(self):
        """Testa que entrada expirada retorna True"""
        entry = CacheEntry(value="test", ttl=0.1)
        time.sleep(0.2)
        assert entry.is_expired()


class TestCacheManager:
    """Testes para CacheManager"""
    
    def test_get_set(self):
        """Testa get e set básicos"""
        cache = CacheManager()
        cache.set("key1", "value1")
        assert cache.get("key1") == "value1"
    
    def test_get_nonexistent(self):
        """Testa get de chave inexistente"""
        cache = CacheManager()
        assert cache.get("nonexistent") is None
    
    def test_expiration(self):
        """Testa expiração de cache"""
        cache = CacheManager()
        cache.set("key1", "value1", ttl=0.1)
        assert cache.get("key1") == "value1"
        time.sleep(0.2)
        assert cache.get("key1") is None
    
    def test_invalidate(self):
        """Testa invalidação de cache"""
        cache = CacheManager()
        cache.set("key1", "value1")
        cache.invalidate("key1")
        assert cache.get("key1") is None
    
    def test_clear(self):
        """Testa limpeza de cache"""
        cache = CacheManager()
        cache.set("key1", "value1")
        cache.set("key2", "value2")
        cache.clear()
        assert cache.get("key1") is None
        assert cache.get("key2") is None
    
    def test_cleanup_expired(self):
        """Testa limpeza de entradas expiradas"""
        cache = CacheManager()
        cache.set("key1", "value1", ttl=0.1)
        cache.set("key2", "value2", ttl=10.0)
        time.sleep(0.2)
        removed = cache.cleanup_expired()
        assert removed == 1
        assert cache.get("key1") is None
        assert cache.get("key2") == "value2"
