# 🖥️ Remote Server Setup

Transforme seu PC Windows + WSL em um servidor remoto completo.

> 🌐 **RSERVER é multiplataforma e open-source!**  
> ✅ Funciona em **Linux**, **macOS** e **Windows**  
> 📖 Veja [INSTALACAO-RAPIDA.md](INSTALACAO-RAPIDA.md) para instalação rápida  
> 🤝 Veja [CONTRIBUTING.md](CONTRIBUTING.md) para contribuir  
> 🔗 **Repositório:** https://github.com/KelvinSilvaDev/rserver

## 🎯 O que você poderá fazer:

- ✅ Acessar via SSH de qualquer lugar
- ✅ Codar remotamente com VS Code
- ✅ Rodar modelos de IA locais (Ollama)
- ✅ Interface Web para modelos de IA (Open WebUI)
- ✅ Geração de imagens com IA (ComfyUI)
- ✅ Acessar o desktop Windows remotamente
- ✅ Conexão segura via VPN (Tailscale)
- ✅ Tunnels permanentes (Cloudflare)

## 📦 Componentes

| Componente | Função |
|------------|--------|
| **SSH** | Acesso ao terminal WSL |
| **Tailscale** | VPN mesh (conexão direta entre dispositivos) |
| **VS Code Server** | Codar remotamente |
| **Ollama** | Rodar LLMs locais (GPU) |
| **Open WebUI** | Interface web para interagir com modelos de IA |
| **ComfyUI** | Interface web para geração de imagens com IA |
| **Cloudflare Tunnel** | Acesso sem abrir portas |
| **RDP** | Desktop remoto Windows |

## 🚀 Quick Start

### Método 1: Scripts Tradicionais

```bash
# 1. Executar setup completo
./setup.sh

# 2. Conectar Tailscale
sudo tailscale up

# 3. Iniciar serviços
./start-server.sh
```

### Método 2: CLI (Recomendado) 🎛️

#### Linux / macOS

```bash
# 1. Instalar CLI
sudo ./cli/install.sh

# 2. Listar serviços disponíveis
rserver list

# 3. Iniciar todos os serviços
rserver start all

# 4. Ou iniciar apenas alguns serviços
rserver start ssh ollama webui

# 5. Verificar status
rserver status
```

#### Windows

```powershell
# 1. Instalar CLI
.\cli\install.ps1

# 2. Usar normalmente
rserver list
rserver start all
rserver status
```

**📖 [Documentação Completa](DOCUMENTACAO.md) | [Instalação por Plataforma](PLATAFORMAS.md)**

## 🎛️ CLI - Remote Server Control

A CLI (`rserver`) permite gerenciar serviços de forma flexível:

- ✅ Iniciar/parar serviços individuais ou todos
- ✅ Verificar status em tempo real
- ✅ Fácil instalação em servidores Linux remotos
- ✅ Configurável via JSON

**Exemplos:**

```bash
# Iniciar apenas serviços essenciais
rserver start ssh ollama webui

# Parar serviços pesados
rserver stop comfyui

# Ver status de um serviço específico
rserver status ollama

# Iniciar todos exceto alguns
rserver start all --exclude comfyui cloudflare
```

## 📚 Documentação

### 🎛️ CLI - Remote Server Control

- **[📖 Documentação Completa](DOCUMENTACAO.md)** - Guia completo e consolidado ⭐
- **[🌐 Suporte Multiplataforma](PLATAFORMAS.md)** - Instalação Linux, macOS, Windows
- **[🚀 Como Publicar](COMO-PUBLICAR.md)** - Distribuição e divulgação
- **[🤝 Guia de Contribuição](CONTRIBUTING.md)** - Como contribuir (open-source)
- **[📑 Índice da Documentação](INDICE.md)** - Navegação rápida
- **[⚡ Quick Start](cli/QUICK-START.md)** - Início rápido

> 💡 **RSERVER é open-source e multiplataforma!** Funciona em qualquer sistema operacional moderno.

### 🖥️ Serviços do Servidor

- [SSH e Acesso Remoto](docs/01-ssh.md)
- [Tailscale VPN](docs/02-tailscale.md)
- [VS Code Remoto](docs/03-vscode.md)
- [Modelos de IA (Ollama)](docs/04-ollama.md)
- [Desktop Remoto](docs/05-rdp.md)

