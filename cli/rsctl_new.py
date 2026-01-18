#!/usr/bin/env python3
"""
Remote Server Control (rserver) - Entry point principal
Versão refatorada com arquitetura profissional
"""

import sys
from pathlib import Path

# Adicionar rsctl ao path
rsctl_path = Path(__file__).parent / "rsctl"
sys.path.insert(0, str(rsctl_path))

from rsctl.cli.parser import create_parser
from rsctl.cli.commands import handle_command


def main():
    """Entry point principal"""
    parser = create_parser()
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    exit_code = handle_command(args)
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
