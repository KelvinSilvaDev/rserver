"""
Interface CLI para rserver
"""

from .parser import create_parser
from .commands import handle_command

__all__ = ['create_parser', 'handle_command']
