# 🎯 Resumo Prático - Como a CLI Funciona

## 📖 O Que É?

A CLI é um **gerenciador inteligente de serviços** do seu servidor remoto. Ela sabe como iniciar, parar e verificar o status de cada serviço.

## 🚀 Nome: `rserver`

**Antes:** `rsctl` (não muito intuitivo)  
**Agora:** `rserver` (claro e amigável!)

```bash
rserver list
rserver start all
rserver status
```

> 💡 **Nota:** `rsctl` ainda funciona para compatibilidade, mas use `rserver`!

## 🔄 Como Funciona (Passo a Passo)

### 1. Você Digita um Comando

```bash
rserver start ssh ollama
```

### 2. CLI Faz o Seguinte:

```
┌─────────────────────────────────────┐
│ 1. Carrega configuração             │
│    (services.json)                  │
│                                     │
│ 2. Valida serviços                   │
│    ✓ "ssh" existe?                  │
│    ✓ "ollama" existe?               │
│                                     │
│ 3. Verifica status (com cache)      │
│    ● Já está rodando? → Pula        │
│    ○ Não está? → Continua           │
│                                     │
│ 4. Executa comando                  │
│    - Tenta start_script primeiro    │
│    - Se não, usa start_cmd          │
│    - Adiciona sudo se necessário     │
│                                     │
│ 5. Aguarda e verifica               │
│    - Espera 2 segundos              │
│    - Verifica se iniciou            │
│                                     │
│ 6. Mostra resultado                 │
│    ✅ Sucesso ou ❌ Erro            │
│                                     │
│ 7. Registra em log                  │
│    (logs/rserver.log)                 │
└─────────────────────────────────────┘
```

## 📋 Comandos Principais

### Listar Serviços
```bash
rserver list
```
**O que faz:** Mostra todos os serviços configurados e se estão rodando (● ou ○)

### Ver Status
```bash
rserver status
```
**O que faz:** Verifica status de todos os serviços (usa cache para ser rápido)

### Iniciar
```bash
rserver start ssh              # Um serviço
rserver start ssh ollama       # Múltiplos
rserver start all              # Todos
rserver start all --exclude comfyui  # Todos exceto alguns
```
**O que faz:** Inicia serviços na ordem definida, verifica se já estão rodando primeiro

### Parar
```bash
rserver stop webui             # Um serviço
rserver stop all               # Todos
rserver stop all --exclude ssh # Todos exceto alguns
```
**O que faz:** Para serviços na ordem reversa

## 💾 Sistema de Cache (Por que é rápido)

### Sem Cache (Lento)
```
Verificar status → Executa comando (100ms)
Verificar status → Executa comando (100ms)  ← Repetido!
Verificar status → Executa comando (100ms)  ← Repetido!
```

### Com Cache (Rápido)
```
Verificar status → Executa comando (100ms) → Salva no cache
Verificar status → Retorna do cache (<1ms) ← Instantâneo!
Verificar status → Retorna do cache (<1ms) ← Instantâneo!
Após 5s → Cache expira → Verifica novamente
```

## 🔍 Como Verifica Status

Cada serviço pode ter um tipo diferente de verificação:

| Tipo | Como Funciona | Exemplo |
|------|---------------|---------|
| **systemd** | `systemctl is-active` | Serviços systemd |
| **docker** | `docker ps` | Containers Docker |
| **http** | `curl` request | Serviços web |
| **port** | `ss -lntp` | Verifica porta |
| **process** | `pgrep` | Processos |

## 📝 Configuração (services.json)

Tudo é definido em um arquivo JSON:

```json
{
  "start_order": ["ssh", "ollama", "webui"],
  "services": {
    "ssh": {
      "display_name": "SSH Server",
      "check_type": "systemd",
      "start_cmd": ["service", "ssh", "start"],
      "stop_cmd": ["service", "ssh", "stop"]
    }
  }
}
```

**Campos importantes:**
- `display_name`: Nome amigável
- `check_type`: Como verificar status
- `start_cmd`: Comando para iniciar
- `stop_cmd`: Comando para parar
- `needs_sudo`: Se precisa sudo (adiciona automaticamente)

## 🎯 Exemplo Real Completo

```bash
# 1. Ver o que tem
$ rserver list
📋 Serviços disponíveis:
  ○ SSH Server (ssh)
  ○ Ollama (ollama)
  ● Web-UI (webui)      ← Já rodando

# 2. Iniciar alguns
$ rserver start ssh ollama
🚀 Iniciando SSH Server...
✅ SSH Server iniciado com sucesso

🚀 Iniciando Ollama...
✅ Ollama iniciado com sucesso

# 3. Ver status
$ rserver status
📊 Status dos Serviços
============================================================
● RODANDO SSH Server
   Porta: 22

● RODANDO Ollama
   Porta: 11434

● RODANDO Web-UI
   Porta: 3000
============================================================

# 4. Parar um
$ rserver stop webui
🛑 Parando Web-UI...
✅ Web-UI parado com sucesso
```

## 🧠 Conceitos Chave

### 1. **Configuração Centralizada**
Um único arquivo (`services.json`) define todos os serviços.

### 2. **Cache Inteligente**
Evita verificações repetidas, tornando a CLI rápida.

### 3. **Verificação Flexível**
Cada serviço pode ter seu próprio método de verificação.

### 4. **Tratamento de Erros**
Erros são capturados, logados e mostrados de forma amigável.

### 5. **Feedback Visual**
Cores e símbolos tornam fácil entender o que está acontecendo.

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
tail -f logs/rserver.log          # Ver logs em tempo real
```

### Validar configuração
```bash
rserver validate                 # Verificar se JSON está correto
```

## 🎯 Resumo em 3 Frases

1. **A CLI lê uma configuração** que define quais serviços existem e como gerenciá-los.
2. **Ela executa comandos** (start/stop) e **verifica resultados** usando diferentes métodos.
3. **Cache e logs** tornam tudo rápido e fácil de debugar.

---

**É basicamente um "gerenciador inteligente" que sabe como lidar com cada tipo de serviço do seu servidor!** 🚀

## 📚 Mais Informação

- **[Resumo Visual](RESUMO-VISUAL.md)**: Diagramas e fluxos
- **[Como Funciona](COMO-FUNCIONA.md)**: Explicação detalhada
- **[Nomes Sugeridos](NOMES-SUGERIDOS.md)**: Por que escolhemos `rserver`
