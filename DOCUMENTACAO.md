# 📚 Documentação Completa - Remote Server Control

## 🎯 Visão Geral

**RSERVER** é uma CLI **open-source** e **multiplataforma** para gerenciar serviços do seu servidor remoto de forma simples, rápida e confiável.

### 🌐 Suporte Multiplataforma

RSERVER funciona em:
- ✅ **Linux** (Ubuntu, Debian, RHEL, Arch, Fedora, etc.)
- ✅ **macOS** (10.14+, Intel e Apple Silicon)
- ✅ **Windows** (10+, PowerShell 5.1+)

> 📖 **Para detalhes de instalação por plataforma, veja [PLATAFORMAS.md](PLATAFORMAS.md)**  
> 🤝 **Para contribuir, veja [CONTRIBUTING.md](CONTRIBUTING.md)**

### O que faz?

- ✅ Inicia/para serviços individuais ou todos de uma vez
- ✅ Verifica status em tempo real (com cache inteligente)
- ✅ Suporta múltiplos tipos de serviços (systemd, docker, http, etc.)
- ✅ Configuração simples via JSON
- ✅ Logs detalhados para debugging
- ✅ Fácil instalação em servidores Linux

---

## 🚀 Início Rápido

### Instalação

#### Linux / macOS

```bash
# Instalação global (recomendado)
sudo ./cli/install.sh

# Instalação do usuário (sem sudo)
INSTALL_DIR=~/.local/bin ./cli/install.sh

# Verificar
rserver --help
```

#### Windows

```powershell
# Executar no PowerShell
.\cli\install.ps1

# Verificar
rserver --help
```

> 📖 **Instruções detalhadas por plataforma: [PLATAFORMAS.md](PLATAFORMAS.md)**

### Primeiros Passos

```bash
# 1. Ver serviços disponíveis
rserver list

# 2. Ver status atual
rserver status

# 3. Iniciar todos os serviços
rserver start all

# 4. Ou iniciar apenas alguns
rserver start ssh ollama webui
```

---

## 📖 Comandos

### `list` - Listar Serviços

Mostra todos os serviços configurados e indica quais estão rodando.

```bash
rserver list
```

**Output:**
```
📋 Serviços disponíveis:

  ● SSH Server (ssh)              ← Rodando
     Servidor SSH para acesso remoto
     Porta: 22

  ○ Ollama (ollama)               ← Parado
     Servidor de modelos de IA locais
     Porta: 11434
```

### `status` - Verificar Status

Verifica o status de um ou todos os serviços.

```bash
# Todos os serviços
rserver status

# Serviço específico
rserver status ollama

# Saída em JSON (útil para scripts)
rserver status --json
```

**Output:**
```
📊 Status dos Serviços
============================================================
● RODANDO SSH Server
   Servidor SSH para acesso remoto
   Porta: 22
   URL: http://localhost:22

○ PARADO Ollama
   Servidor de modelos de IA locais
   Porta: 11434
   URL: http://localhost:11434
============================================================
```

### `start` - Iniciar Serviços

Inicia um ou mais serviços.

```bash
# Um serviço
rserver start ssh

# Múltiplos serviços
rserver start ssh ollama webui

# Todos os serviços
rserver start all

# Todos exceto alguns
rserver start all --exclude comfyui cloudflare

# Opções avançadas
rserver start ssh --timeout 60        # Timeout customizado
rserver start ssh --no-wait           # Não aguarda serviço ficar pronto
```

**O que acontece:**
1. Valida se o serviço existe
2. Verifica se já está rodando (pula se já estiver)
3. Executa comando de start
4. Aguarda 2 segundos
5. Verifica se iniciou com sucesso
6. Mostra resultado

### `stop` - Parar Serviços

Para um ou mais serviços.

```bash
# Um serviço
rserver stop webui

# Múltiplos serviços
rserver stop webui comfyui

# Todos os serviços
rserver stop all

# Todos exceto alguns
rserver stop all --exclude ssh

# Timeout customizado
rserver stop webui --timeout 30
```

### `validate` - Validar Configuração

Valida o arquivo de configuração JSON.

```bash
rserver validate

# Ou com arquivo específico
rserver validate --config /caminho/para/services.json
```

---

## ⚙️ Configuração

### Arquivo de Configuração

A configuração está em `cli/services.json`. Este arquivo define:
- Quais serviços existem
- Como iniciar/parar cada um
- Como verificar o status
- Ordem de inicialização

### Estrutura Básica

```json
{
  "start_order": ["ssh", "ollama", "webui"],
  "services": {
    "ssh": {
      "display_name": "SSH Server",
      "description": "Servidor SSH para acesso remoto",
      "port": 22,
      "check_type": "systemd",
      "needs_sudo": true,
      "start_cmd": ["service", "ssh", "start"],
      "stop_cmd": ["service", "ssh", "stop"]
    }
  }
}
```

### Campos Principais

| Campo | Descrição | Obrigatório |
|-------|-----------|-------------|
| `display_name` | Nome amigável mostrado ao usuário | ✅ Sim |
| `check_type` | Tipo de verificação (systemd, docker, http, port, process) | ✅ Sim |
| `start_cmd` | Comando para iniciar (array) | ⚠️ Start ou script |
| `start_script` | Script bash para iniciar | ⚠️ Start ou script |
| `stop_cmd` | Comando para parar (array) | ⚠️ Stop ou script |
| `stop_script` | Script bash para parar | ⚠️ Stop ou script |
| `needs_sudo` | Se precisa sudo (adiciona automaticamente) | ❌ Não |
| `port` | Porta do serviço | ❌ Não |
| `url` | URL do serviço | ❌ Não |

### Tipos de Verificação (`check_type`)

#### `systemd`
Para serviços gerenciados pelo systemd.

```json
{
  "check_type": "systemd",
  "systemd_name": "ssh"  // Opcional, usa nome do serviço se omitido
}
```

#### `docker`
Para containers Docker.

```json
{
  "check_type": "docker",
  "container_name": "open-webui"  // Obrigatório
}
```

#### `http`
Para serviços web (faz requisição HTTP).

```json
{
  "check_type": "http",
  "check_url": "http://localhost:3000",  // Opcional
  "port": 3000  // Usado se check_url não especificado
}
```

#### `port`
Verifica se uma porta está aberta.

```json
{
  "check_type": "port",
  "port": 22  // Obrigatório
}
```

#### `process`
Verifica se um processo está rodando.

```json
{
  "check_type": "process",
  "process_name": "tailscaled"  // Obrigatório
}
```

### Adicionar Novo Serviço

1. **Edite `cli/services.json`**:

```json
{
  "services": {
    "meu-servico": {
      "display_name": "Meu Serviço",
      "description": "Descrição do serviço",
      "port": 8080,
      "check_type": "http",
      "check_url": "http://localhost:8080",
      "start_cmd": ["systemctl", "start", "meu-servico"],
      "stop_cmd": ["systemctl", "stop", "meu-servico"],
      "needs_sudo": true
    }
  },
  "start_order": ["ssh", "meu-servico", "ollama"]
}
```

2. **Valide a configuração**:

```bash
rserver validate
```

3. **Teste**:

```bash
rserver start meu-servico
rserver status meu-servico
```

---

## 🔍 Como Funciona

### Fluxo de Execução

```
1. Você digita: rserver start ssh
   ↓
2. CLI carrega: services.json
   ↓
3. Valida: Serviço "ssh" existe?
   ↓
4. Verifica cache: Já está rodando? (cache de 5s)
   ↓
5. Se não está rodando:
   - Executa start_cmd ou start_script
   - Aguarda 2 segundos
   - Verifica se iniciou
   ↓
6. Mostra resultado: ✅ ou ❌
   ↓
7. Registra em log: logs/rserver.log
```

### Sistema de Cache

O cache torna a CLI rápida evitando verificações repetidas:

- **Primeira verificação**: Executa comando (pode ser lento)
- **Próximas 5 segundos**: Retorna do cache (instantâneo!)
- **Após 5 segundos**: Cache expira, verifica novamente

**Cache é invalidado quando:**
- Você inicia um serviço
- Você para um serviço
- Após 5 segundos (TTL)

### Verificação de Status

Cada tipo de serviço tem seu próprio método:

| Tipo | Comando | Quando Usar |
|------|---------|-------------|
| `systemd` | `systemctl is-active` | Serviços systemd |
| `docker` | `docker ps` | Containers Docker |
| `http` | `curl` | Serviços web |
| `port` | `ss -lntp` | Qualquer serviço com porta |
| `process` | `pgrep` | Processos genéricos |

---

## 📋 Serviços Disponíveis

| Serviço | Nome | Descrição | Porta |
|---------|------|-----------|-------|
| `ssh` | SSH Server | Servidor SSH para acesso remoto | 22 |
| `tailscale` | Tailscale VPN | VPN mesh para acesso seguro | - |
| `ollama` | Ollama | Servidor de modelos de IA locais | 11434 |
| `webui` | Open WebUI | Interface web para modelos de IA | 3000 |
| `comfyui` | ComfyUI | Interface web para geração de imagens | 8188 |
| `cloudflare` | Cloudflare Tunnels | Túneis para acesso remoto | - |

---

## 💡 Casos de Uso Comuns

### Iniciar Apenas Serviços Essenciais

```bash
rserver start ssh ollama webui
```

### Economizar Recursos

```bash
# Parar serviços pesados
rserver stop comfyui cloudflare
```

### Reiniciar um Serviço

```bash
rserver stop ollama
rserver start ollama
```

### Verificar Antes de Iniciar Tudo

```bash
rserver status
rserver start all
```

### Debugging

```bash
# Modo verboso (mais informações)
rserver --verbose start ssh

# Ver logs em tempo real
tail -f logs/rserver.log

# Validar configuração
rserver validate
```

---

## 🌐 Instalação em Servidor Remoto

### Linux / macOS

```bash
# Método 1: Git Clone
git clone https://github.com/KelvinSilvaDev/rserver.git /opt/remote-server
cd /opt/remote-server
sudo ./cli/install.sh

# Método 2: SCP
scp -r cli/ user@servidor:/opt/remote-server/
ssh user@servidor "cd /opt/remote-server && sudo ./cli/install.sh"
```

### Windows (PowerShell Remoto)

```powershell
# Conectar via SSH (se configurado)
ssh user@servidor

# Ou usar PowerShell Remoting
Enter-PSSession -ComputerName servidor

# Executar instalação
.\cli\install.ps1
```

### Verificar Instalação

**Linux/macOS:**
```bash
which rserver
rserver --help
```

**Windows:**
```powershell
Get-Command rserver
rserver --help
```

---

## 🐛 Troubleshooting

### Comando não encontrado

```bash
# Verificar PATH
echo $PATH

# Adicionar ao PATH
export PATH="$PATH:/usr/local/bin"

# Ou usar caminho completo
/usr/local/bin/rserver --help
```

### Erro de permissão

Alguns serviços precisam de `sudo`. O rserver adiciona automaticamente, mas você pode precisar configurar sudoers:

```bash
sudo visudo
# Adicionar:
seu_usuario ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/sbin/service
```

### Serviço não inicia

```bash
# Verificar status
rserver status nome_servico

# Ver logs
tail -f logs/rserver.log

# Verificar manualmente
systemctl status nome_servico  # Para systemd
docker ps                      # Para Docker
```

### Configuração inválida

```bash
# Validar configuração
rserver validate

# Verificar sintaxe JSON
cat cli/services.json | python3 -m json.tool
```

---

## 🔧 Opções Avançadas

### Flags Globais

```bash
# Modo verboso (mais informações)
rserver --verbose start ssh

# Modo quiet (menos output)
rserver --quiet start all

# Especificar arquivo de configuração
rserver --config /caminho/para/config.json start all
```

### Timeouts

```bash
# Timeout customizado (padrão: 30s)
rserver start ssh --timeout 60
rserver stop webui --timeout 15
```

### Não Aguardar Pronto

```bash
# Inicia mas não verifica se ficou pronto
rserver start ssh --no-wait
```

### Saída JSON

```bash
# Útil para scripts e automação
rserver status --json
rserver list --json
```

---

## 📊 Logs

### Localização

```
logs/rserver.log
```

### Níveis de Log

- **DEBUG**: Detalhes técnicos (apenas com `--verbose`)
- **INFO**: Operações normais
- **WARNING**: Situações que podem causar problemas
- **ERROR**: Erros que não impedem execução
- **CRITICAL**: Erros que impedem execução

### Ver Logs

```bash
# Ver últimas linhas
tail logs/rserver.log

# Ver em tempo real
tail -f logs/rserver.log

# Buscar erros
grep ERROR logs/rserver.log
```

---

## 🎯 Exemplos Completos

### Exemplo 1: Setup Inicial

```bash
# 1. Instalar
sudo ./cli/install.sh

# 2. Verificar
rserver list

# 3. Iniciar serviços essenciais
rserver start ssh ollama webui

# 4. Verificar status
rserver status
```

### Exemplo 2: Gerenciamento Diário

```bash
# Manhã: Iniciar tudo
rserver start all

# Tarde: Parar serviços pesados para economizar
rserver stop comfyui

# Noite: Verificar o que está rodando
rserver status

# Reiniciar um serviço
rserver stop ollama && rserver start ollama
```

### Exemplo 3: Debugging

```bash
# Serviço não inicia
rserver --verbose start webui
tail -f logs/rserver.log

# Verificar configuração
rserver validate

# Verificar manualmente
docker ps | grep webui
```

---

## 📚 Estrutura do Projeto

```
remote-server/
├── cli/
│   ├── rsctl_new.py          # Entry point principal
│   ├── services.json          # Configuração dos serviços
│   ├── install.sh            # Script de instalação
│   ├── src/                  # Código fonte
│   │   ├── core/             # Funcionalidade core
│   │   ├── cli/              # Interface CLI
│   │   └── utils/            # Utilitários
│   └── scripts/              # Scripts auxiliares
├── logs/                     # Logs da aplicação
└── docs/                     # Documentação adicional
```

---

## 🔗 Links Úteis

- **Suporte Multiplataforma**: [PLATAFORMAS.md](PLATAFORMAS.md) - Instalação e compatibilidade
- **Guia de Contribuição**: [CONTRIBUTING.md](CONTRIBUTING.md) - Como contribuir
- **Documentação Principal**: [README.md](README.md)
- **Guia de Desenvolvimento**: [cli/docs/DEVELOPMENT.md](cli/docs/DEVELOPMENT.md)
- **Arquitetura**: [cli/docs/ARCHITECTURE.md](cli/docs/ARCHITECTURE.md)
- **Instalação Remota**: [cli/INSTALL-REMOTE.md](cli/INSTALL-REMOTE.md)

---

## 💬 Suporte

- **Issues**: Reporte problemas no repositório
- **Logs**: Verifique `logs/rserver.log` para detalhes
- **Validação**: Use `rserver validate` para verificar configuração

---

**Desenvolvido com foco em simplicidade, robustez e performance!** 🚀
