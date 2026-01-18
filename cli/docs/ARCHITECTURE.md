# 🏗️ Arquitetura do RSERVER

## Visão Geral

O RSERVER foi projetado com foco em:
- **Modularidade**: Código organizado em módulos independentes
- **Extensibilidade**: Fácil adicionar novos serviços e funcionalidades
- **Robustez**: Tratamento de erros completo e validações
- **Performance**: Cache inteligente e operações otimizadas
- **Testabilidade**: Código testável com mocks e fixtures

## Estrutura de Diretórios

```
cli/
├── rsctl.py              # Entry point legado (compatibilidade)
├── rsctl_new.py           # Entry point novo (refatorado)
├── src/                   # Código fonte modular
│   ├── __init__.py
│   ├── core/             # Funcionalidade core
│   │   ├── manager.py    # ServiceManager principal
│   │   ├── config.py     # Gerenciamento de configuração
│   │   ├── cache.py      # Sistema de cache
│   │   └── validator.py # Validações
│   ├── cli/              # Interface CLI
│   │   ├── parser.py     # Argument parsing
│   │   └── commands.py   # Handlers de comandos
│   └── utils/            # Utilitários
│       ├── logger.py     # Sistema de logging
│       ├── colors.py     # Formatação de output
│       └── exceptions.py # Exceções customizadas
├── tests/                # Testes
│   ├── unit/            # Testes unitários
│   ├── integration/     # Testes de integração
│   └── fixtures/        # Dados de teste
├── config/              # Configurações
│   └── services.json    # Configuração de serviços
└── scripts/             # Scripts auxiliares
```

## Fluxo de Execução

### 1. Entry Point

```python
# rsctl_new.py
main() → create_parser() → handle_command()
```

### 2. Parsing

```python
# cli/parser.py
create_parser() → ArgumentParser com subcommands
```

### 3. Command Handling

```python
# cli/commands.py
handle_command() → handle_start/stop/status/list()
```

### 4. Service Management

```python
# core/manager.py
ServiceManager.start_service() → _run_command() → _check_service_running()
```

## Componentes Principais

### ServiceManager

**Responsabilidades:**
- Gerenciar ciclo de vida dos serviços
- Verificar status dos serviços
- Executar comandos de start/stop
- Gerenciar cache de status

**Dependências:**
- ConfigManager: Carregar configuração
- CacheManager: Cache de status
- Validators: Validar serviços

### ConfigManager

**Responsabilidades:**
- Carregar configuração JSON
- Validar estrutura da configuração
- Fornecer acesso tipado à configuração
- Recarregar configuração quando necessário

### CacheManager

**Responsabilidades:**
- Cachear resultados de verificações
- Gerenciar TTL (Time To Live)
- Limpar entradas expiradas
- Thread-safe operations

### Validators

**Responsabilidades:**
- Validar estrutura de configuração
- Verificar dependências do sistema
- Validar serviços antes de operações

## Padrões de Design

### 1. Strategy Pattern

Diferentes tipos de verificação de status (systemd, docker, http, etc.) são implementados como estratégias no método `_check_service_running()`.

### 2. Factory Pattern

`ServiceManager` cria instâncias de validadores e managers conforme necessário.

### 3. Singleton Pattern

Loggers são singletons gerenciados pelo módulo `logging`.

### 4. Command Pattern

Cada comando CLI (start, stop, status) é um handler separado.

## Tratamento de Erros

### Hierarquia de Exceções

```
RSCTLError (base)
├── ConfigError
├── ServiceNotFoundError
├── ServiceStartError
├── ServiceStopError
├── ServiceCheckError
├── CommandExecutionError
├── DependencyError
└── PermissionError
```

### Fluxo de Tratamento

1. **Validação**: Validar input antes de executar
2. **Try/Except**: Capturar exceções específicas
3. **Logging**: Registrar erros com contexto
4. **User Feedback**: Mostrar mensagens amigáveis
5. **Exit Codes**: Retornar códigos apropriados

## Cache Strategy

### Cache de Status

- **TTL**: 5 segundos (configurável)
- **Chave**: `status:{service_name}`
- **Invalidation**: Após start/stop

### Cache de Configuração

- **TTL**: Infinito (até reload manual)
- **Chave**: `config`
- **Invalidation**: Apenas manual

## Logging

### Estrutura

```
logs/
└── rserver.log (rotating, 10MB, 5 backups)
```

### Níveis

- **DEBUG**: Informações detalhadas (apenas com --verbose)
- **INFO**: Operações normais
- **WARNING**: Situações que podem causar problemas
- **ERROR**: Erros que não impedem execução
- **CRITICAL**: Erros que impedem execução

## Performance

### Otimizações

1. **Cache**: Reduz verificações repetidas
2. **Lazy Loading**: Carregar config apenas quando necessário
3. **Timeouts**: Evitar hangs em comandos lentos
4. **Parallel Checks**: Verificar múltiplos serviços em paralelo (futuro)

### Métricas

- Tempo médio de verificação de status: < 100ms (com cache)
- Tempo médio de start: 2-5s (depende do serviço)
- Overhead de cache: < 1ms

## Extensibilidade

### Adicionar Novo Serviço

1. Adicionar entrada em `services.json`
2. Configurar `check_type` apropriado
3. Definir `start_cmd` ou `start_script`
4. Testar com `rserver validate`

### Adicionar Novo Tipo de Verificação

1. Adicionar novo `check_type` em `validator.py`
2. Implementar lógica em `_check_service_running()`
3. Adicionar validação em `ConfigValidator`

### Adicionar Novo Comando CLI

1. Adicionar subparser em `parser.py`
2. Criar handler em `commands.py`
3. Adicionar lógica em `ServiceManager` se necessário

## Segurança

### Validações

- Validar todos os inputs do usuário
- Sanitizar comandos antes de executar
- Verificar permissões antes de operações privilegiadas

### Execução de Comandos

- Usar `subprocess.run()` com `shell=False`
- Validar comandos antes de executar
- Timeouts em todos os comandos
- Não logar informações sensíveis

## Testes

### Estrutura

- **Unit Tests**: Testar funções isoladamente
- **Integration Tests**: Testar interação entre componentes
- **Mocking**: Mockar subprocess, filesystem, network

### Cobertura

- Meta: 80% de cobertura
- Foco: Lógica de negócio e tratamento de erros

## Futuras Melhorias

1. **Async/Await**: Operações assíncronas para I/O
2. **Plugin System**: Sistema de plugins para serviços
3. **Health Checks**: Verificações de saúde mais robustas
4. **Metrics**: Coleta de métricas de performance
5. **API REST**: API HTTP para controle remoto
6. **Web UI**: Interface web para gerenciamento
