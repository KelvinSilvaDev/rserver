"""
Comandos CLI
"""

import sys
import json
from pathlib import Path
from typing import Optional

from ..core.manager import ServiceManager
from ..core.config import ConfigManager
from ..core.validator import ConfigValidator
from ..utils import (
    setup_logger,
    get_logger,
    fmt,
    RSCTLError,
    ConfigError,
    ServiceNotFoundError,
)
from .parser import create_parser

logger = get_logger(__name__)


def main():
    """Entry point para console_scripts"""
    parser = create_parser()
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    exit_code = handle_command(args)
    sys.exit(exit_code)


def handle_command(args) -> int:
    """
    Processa e executa comando CLI.
    
    Args:
        args: Argumentos parseados
        
    Returns:
        Código de saída (0 = sucesso, != 0 = erro)
    """
    # Configurar logging baseado em flags
    import logging
    log_level = logging.DEBUG if args.verbose else logging.INFO
    console_level = logging.WARNING if args.quiet else logging.INFO
    
    log_file = Path(__file__).parent.parent.parent.parent / "logs" / "rserver.log"
    setup_logger("rserver", log_file, level=log_level, console_level=console_level)
    
    try:
        # Configurar caminho de configuração
        config_path = None
        if args.config:
            config_path = Path(args.config)
        elif hasattr(args, 'config') and args.config:
            config_path = Path(args.config)
        
        # Criar manager
        manager = ServiceManager(config_path=config_path)
        
        # Executar comando
        if args.command == "start":
            return handle_start(manager, args)
        elif args.command == "stop":
            return handle_stop(manager, args)
        elif args.command == "status":
            return handle_status(manager, args)
        elif args.command == "list":
            return handle_list(manager, args)
        elif args.command == "validate":
            return handle_validate(args)
        else:
            logger.error(f"Comando desconhecido: {args.command}")
            return 1
    
    except KeyboardInterrupt:
        print(f"\n{fmt.warning('Operação cancelada pelo usuário')}")
        logger.info("Operação cancelada pelo usuário")
        return 130  # SIGINT
    
    except RSCTLError as e:
        logger.error(f"Erro do rserver: {e}")
        print(fmt.error(str(e)))
        if args.verbose and e.details:
            print(fmt.dim(f"Detalhes: {e.details}"))
        return 1
    
    except Exception as e:
        logger.exception(f"Erro inesperado: {e}")
        print(fmt.error(f"Erro inesperado: {e}"))
        if args.verbose:
            import traceback
            print(fmt.dim(traceback.format_exc()))
        return 1


def handle_start(manager: ServiceManager, args) -> int:
    """Processa comando start"""
    if "all" in args.services:
        results = manager.start_all(exclude=args.exclude)
        # Verificar se algum falhou
        if any(not success for success in results.values()):
            return 1
        return 0
    else:
        success = True
        for service in args.services:
            try:
                result = manager.start_service(
                    service,
                    timeout=args.timeout,
                    wait_for_ready=not args.no_wait
                )
                if not result:
                    success = False
            except ServiceNotFoundError as e:
                print(fmt.error(str(e)))
                success = False
            except Exception as e:
                logger.exception(f"Erro ao iniciar {service}: {e}")
                print(fmt.error(f"Erro ao iniciar {service}: {e}"))
                success = False
            print()  # Linha em branco
        
        return 0 if success else 1


def handle_stop(manager: ServiceManager, args) -> int:
    """Processa comando stop"""
    if "all" in args.services:
        results = manager.stop_all(exclude=args.exclude)
        # Verificar se algum falhou
        if any(not success for success in results.values()):
            return 1
        return 0
    else:
        success = True
        for service in args.services:
            try:
                result = manager.stop_service(service, timeout=args.timeout)
                if not result:
                    success = False
            except ServiceNotFoundError as e:
                print(fmt.error(str(e)))
                success = False
            except Exception as e:
                logger.exception(f"Erro ao parar {service}: {e}")
                print(fmt.error(f"Erro ao parar {service}: {e}"))
                success = False
            print()  # Linha em branco
        
        return 0 if success else 1


def handle_status(manager: ServiceManager, args) -> int:
    """Processa comando status"""
    status = manager.get_status(args.service)
    
    if args.json:
        print(json.dumps(status, indent=2, ensure_ascii=False))
        return 0
    
    # Formatação bonita
    print(fmt.bold("📊 Status dos Serviços\n"))
    print("=" * 60)
    
    for name, info in status.items():
        if info["running"]:
            status_icon = fmt.status_running("RODANDO")
        else:
            status_icon = fmt.status_stopped("PARADO")
        
        print(f"\n{status_icon} {info['display_name']}")
        if info["description"]:
            print(f"   {fmt.dim(info['description'])}")
        if info["port"]:
            print(f"   Porta: {info['port']}")
        if info["url"]:
            print(f"   URL: {info['url']}")
    
    print("\n" + "=" * 60)
    return 0


def handle_list(manager: ServiceManager, args) -> int:
    """Processa comando list"""
    services = manager.config.get("services", {})
    
    if args.json:
        print(json.dumps(services, indent=2, ensure_ascii=False))
        return 0
    
    print(fmt.bold("📋 Serviços disponíveis:\n"))
    
    for name, config in services.items():
        display_name = config.get("display_name", name)
        description = config.get("description", "")
        
        # Verificar status
        try:
            is_running = manager._check_service_running(name)
            if is_running:
                status_icon = fmt.status_running("")
            else:
                status_icon = fmt.status_stopped("")
        except Exception:
            status_icon = fmt.status_stopped("")
        
        print(f"  {status_icon} {display_name} ({name})")
        if description:
            print(f"     {fmt.dim(description)}")
        if config.get("port"):
            print(f"     Porta: {config.get('port')}")
        print()
    
    return 0


def handle_validate(args) -> int:
    """Processa comando validate"""
    config_path = None
    if args.config:
        config_path = Path(args.config)
    else:
        config_path = ConfigManager._default_config_path()
    
    print(fmt.progress(f"Validando configuração: {config_path}"))
    
    try:
        config_manager = ConfigManager(config_path)
        config = config_manager.load(validate=True)
        
        print(fmt.success("✅ Configuração válida!"))
        print(f"   {len(config.get('services', {}))} serviço(s) configurado(s)")
        return 0
    
    except ConfigError as e:
        print(fmt.error(f"❌ Erro na configuração: {e}"))
        if hasattr(e, 'details') and e.details:
            print(fmt.dim(f"   {e.details}"))
        return 1
    
    except Exception as e:
        print(fmt.error(f"❌ Erro ao validar: {e}"))
        return 1
