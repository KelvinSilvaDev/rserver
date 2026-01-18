# 🎯 Como a CLI Funciona - Resumo Prático

## 📖 Conceito Básico

A CLI é um **gerenciador de serviços** que permite iniciar/parar/verificar serviços do seu servidor remoto de forma simples e organizada.

## 🔄 Fluxo Simples

```
Você digita → CLI valida → Executa comando → Verifica resultado → Mostra feedback
```

## 📋 Exemplo Prático

### 1. Listar Serviços Disponíveis

```bash
rserver list
```

**O que acontece:**
1. CLI carrega `services.json`
2. Mostra todos os serviços configurados
3. Indica quais estão rodando (●) ou parados (○)

**Output:**
```
📋 Serviços disponíveis:

  ○ SSH Server (ssh)
     Servidor SSH para acesso remoto
     Porta: 22

  ● Ollama (ollama)
     Servidor de modelos de IA locais
     Porta: 11434
```

### 2. Verificar Status

```bash
rserver status
```

**O que acontece:**
1. Para cada serviço, verifica se está rodando
2. Usa cache (5 segundos) para não verificar repetidamente
3. Mostra status formatado

**Tipos de verificação:**
- `systemd`: Verifica com `systemctl is-active`
- `docker`: Verifica se container está rodando
- `http`: Faz requisição HTTP para verificar
- `port`: Verifica se porta está aberta
- `process`: Verifica se processo está rodando

### 3. Iniciar Serviços

```bash
rserver start ssh ollama
```

**O que acontece:**
1. Valida se serviços existem na configuração
2. Verifica se já estão rodando (pula se já estiver)
3. Executa comando de start (script ou comando direto)
4. Aguarda 2 segundos
5. Verifica se iniciou com sucesso
6. Mostra feedback colorido

**Ordem de tentativas:**
1. Primeiro tenta `start_script` (se configurado)
2. Se não, tenta `start_cmd` (comando direto)
3. Se precisa sudo, adiciona automaticamente

### 4. Parar Serviços

```bash
rserver stop webui
```

**O que acontece:**
1. Valida se serviço existe
2. Verifica se está rodando (se não, apenas informa)
3. Executa comando de stop
4. Invalida cache do status
5. Mostra feedback

### 5. Iniciar Todos

```bash
rserver start all
```

**O que acontece:**
1. Pega ordem definida em `start_order` do JSON
2. Inicia cada serviço na ordem
3. Respeita dependências (ex: SSH antes de outros)
4. Mostra progresso de cada um

**Excluir alguns:**
```bash
rserver start all --exclude comfyui cloudflare
```

## 🧠 Sistema de Cache

### Por que cache?

Verificar status de serviços pode ser lento (requisições HTTP, comandos systemd, etc.). O cache evita verificações repetidas desnecessárias.

### Como funciona:

```
Primeira verificação → Executa comando → Salva no cache (5s)
Segunda verificação (< 5s) → Retorna do cache (rápido!)
Após 5 segundos → Cache expira → Verifica novamente
```

### Quando cache é invalidado:

- Após `start` de um serviço
- Após `stop` de um serviço
- Manualmente com `cache.cleanup_expired()`

## ⚙️ Configuração (services.json)

### Estrutura Básica

```json
{
  "start_order": ["ssh", "ollama", "webui"],
  "services": {
    "ssh": {
      "display_name": "SSH Server",
      "check_type": "systemd",
      "start_cmd": ["service", "ssh", "start"]
    }
  }
}
```

### Campos Importantes

- **display_name**: Nome amigável mostrado ao usuário
- **check_type**: Como verificar se está rodando
- **start_cmd**: Comando para iniciar
- **stop_cmd**: Comando para parar
- **start_script**: Script bash para iniciar (opcional)
- **needs_sudo**: Se precisa de sudo (adiciona automaticamente)

## 🔍 Verificação de Status - Detalhes

### systemd
```bash
systemctl is-active --quiet nome-servico
# Retorna 0 se ativo, != 0 se inativo
```

### docker
```bash
docker ps --format "{{.Names}}"
# Verifica se nome do container está na lista
```

### http
```bash
curl -s --max-time 2 http://localhost:8080
# Retorna 0 se servidor responde
```

### port
```bash
ss -lntp | grep ":8080"
# Verifica se porta está aberta
```

### process
```bash
pgrep -f "nome-processo"
# Retorna 0 se processo existe
```

## 🚨 Tratamento de Erros

### Hierarquia de Exceções

```
RSCTLError (base)
├── ServiceNotFoundError → Serviço não existe
├── ServiceStartError → Falha ao iniciar
├── ServiceStopError → Falha ao parar
├── CommandExecutionError → Comando falhou
└── ConfigError → Erro na configuração
```

### O que acontece em caso de erro:

1. **Erro capturado** → Logado no arquivo de log
2. **Mensagem amigável** → Mostrada ao usuário
3. **Exit code** → Retornado (0 = sucesso, != 0 = erro)
4. **Detalhes** → Mostrados com `--verbose`

## 📊 Logging

### Onde ficam os logs?

```
logs/rserver.log
```

### Níveis de Log

- **DEBUG**: Detalhes técnicos (apenas com `--verbose`)
- **INFO**: Operações normais (start, stop, status)
- **WARNING**: Situações que podem causar problemas
- **ERROR**: Erros que não impedem execução
- **CRITICAL**: Erros que impedem execução

### Exemplo de log:

```
2024-01-15 10:30:45 - rserver - INFO - ServiceManager inicializado
2024-01-15 10:30:46 - rserver - INFO - Iniciando SSH Server...
2024-01-15 10:30:48 - rserver - INFO - SSH Server iniciado com sucesso
```

## 🎨 Output Formatado

### Cores e Símbolos

- ✅ **Verde**: Sucesso
- ❌ **Vermelho**: Erro
- ⚠️ **Amarelo**: Aviso
- ℹ️ **Azul**: Informação
- 🚀 **Ciano**: Progresso
- ● **Verde**: Rodando
- ○ **Vermelho**: Parado

### Modos de Output

**Normal:**
```bash
rserver status
# Output formatado com cores
```

**JSON:**
```bash
rserver status --json
# Output em JSON (útil para scripts)
```

**Quiet:**
```bash
rserver --quiet start ssh
# Menos output, apenas essencial
```

**Verbose:**
```bash
rserver --verbose start ssh
# Mais detalhes, logs DEBUG
```

## 🔄 Fluxo Completo: Iniciar Serviço

```
1. Usuário: rserver start ssh
   ↓
2. Parser: Valida argumentos
   ↓
3. Commands: handle_start()
   ↓
4. Manager: start_service("ssh")
   ↓
5. Validator: Valida se "ssh" existe
   ↓
6. Cache: Verifica cache de status
   ↓
7. Check: _check_service_running()
   - Se já rodando → Retorna sucesso
   - Se não → Continua
   ↓
8. Start: Executa start_cmd ou start_script
   ↓
9. Wait: Aguarda 2 segundos
   ↓
10. Verify: Verifica se iniciou
    ↓
11. Cache: Invalida cache
    ↓
12. Output: Mostra resultado formatado
    ↓
13. Log: Registra no log
    ↓
14. Exit: Retorna código de saída
```

## 💡 Dicas Práticas

### Verificar antes de iniciar tudo

```bash
rserver status        # Ver o que está rodando
rserver start all     # Iniciar tudo
```

### Iniciar apenas essenciais

```bash
rserver start ssh ollama webui
```

### Economizar recursos

```bash
rserver stop comfyui cloudflare  # Para serviços pesados
```

### Debugging

```bash
rserver --verbose start ssh      # Ver detalhes
tail -f logs/rserver.log         # Ver logs em tempo real
```

### Validar configuração

```bash
rserver validate                 # Verificar se JSON está correto
```

## 🎯 Resumo em 3 Linhas

1. **CLI lê configuração** (`services.json`) que define serviços e como gerenciá-los
2. **Executa comandos** (start/stop) e **verifica status** usando diferentes métodos (systemd, docker, http, etc.)
3. **Cache otimiza** verificações repetidas e **logs registram** tudo para debugging

---

**Simples assim!** A CLI é basicamente um **orquestrador inteligente** que sabe como gerenciar cada tipo de serviço do seu servidor. 🚀
