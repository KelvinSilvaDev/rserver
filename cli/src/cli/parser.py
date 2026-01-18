"""
Parser de argumentos CLI
"""

import argparse
from typing import Optional


def create_parser() -> argparse.ArgumentParser:
    """
    Cria e configura parser de argumentos CLI.
    
    Returns:
        ArgumentParser configurado
    """
    parser = argparse.ArgumentParser(
        prog="rserver",
        description="Remote Server Control - Gerencia serviços do servidor remoto de forma profissional",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  rserver start all                    # Inicia todos os serviços
  rserver start ssh ollama             # Inicia apenas SSH e Ollama
  rserver start all --exclude comfyui  # Inicia todos exceto ComfyUI
  rserver stop webui                    # Para o Web-UI
  rserver status                        # Mostra status de todos os serviços
  rserver status ollama                 # Mostra status do Ollama
  rserver list                          # Lista serviços disponíveis
        """
    )
    
    parser.add_argument(
        '--version',
        action='version',
        version='%(prog)s 1.0.0'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Modo verboso (mais informações)'
    )
    
    parser.add_argument(
        '--quiet', '-q',
        action='store_true',
        help='Modo silencioso (menos output)'
    )
    
    parser.add_argument(
        '--config',
        type=str,
        help='Caminho para arquivo de configuração'
    )
    
    subparsers = parser.add_subparsers(
        dest="command",
        help="Comando a executar",
        metavar="COMMAND"
    )
    
    # Comando start
    start_parser = subparsers.add_parser(
        "start",
        help="Inicia serviços",
        description="Inicia um ou mais serviços"
    )
    start_parser.add_argument(
        "services",
        nargs="+",
        metavar="SERVICE",
        help="Serviços para iniciar (use 'all' para todos)"
    )
    start_parser.add_argument(
        "--exclude",
        nargs="+",
        default=[],
        metavar="SERVICE",
        help="Serviços para excluir ao iniciar todos"
    )
    start_parser.add_argument(
        "--no-wait",
        action="store_true",
        help="Não aguarda serviço ficar pronto"
    )
    start_parser.add_argument(
        "--timeout",
        type=int,
        default=30,
        help="Timeout em segundos (padrão: 30)"
    )
    
    # Comando stop
    stop_parser = subparsers.add_parser(
        "stop",
        help="Para serviços",
        description="Para um ou mais serviços"
    )
    stop_parser.add_argument(
        "services",
        nargs="+",
        metavar="SERVICE",
        help="Serviços para parar (use 'all' para todos)"
    )
    stop_parser.add_argument(
        "--exclude",
        nargs="+",
        default=[],
        metavar="SERVICE",
        help="Serviços para excluir ao parar todos"
    )
    stop_parser.add_argument(
        "--timeout",
        type=int,
        default=30,
        help="Timeout em segundos (padrão: 30)"
    )
    
    # Comando status
    status_parser = subparsers.add_parser(
        "status",
        help="Mostra status dos serviços",
        description="Mostra status de um ou todos os serviços"
    )
    status_parser.add_argument(
        "service",
        nargs="?",
        metavar="SERVICE",
        help="Serviço específico (opcional, mostra todos se omitido)"
    )
    status_parser.add_argument(
        "--json",
        action="store_true",
        help="Saída em formato JSON"
    )
    
    # Comando list
    list_parser = subparsers.add_parser(
        "list",
        help="Lista serviços disponíveis",
        description="Lista todos os serviços configurados"
    )
    list_parser.add_argument(
        "--json",
        action="store_true",
        help="Saída em formato JSON"
    )
    
    # Comando validate
    validate_parser = subparsers.add_parser(
        "validate",
        help="Valida configuração",
        description="Valida arquivo de configuração"
    )
    validate_parser.add_argument(
        "--config",
        type=str,
        help="Caminho para arquivo de configuração"
    )
    
    return parser
