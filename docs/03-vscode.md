# 💻 VS Code Remoto

## Opção 1: VS Code + SSH (Recomendado)

### No Notebook:

1. Instale a extensão **Remote - SSH** no VS Code
2. Pressione `Ctrl+Shift+P` → "Remote-SSH: Connect to Host"
3. Digite: `kelvin@100.x.x.x` (IP Tailscale)

### Configurar SSH no VS Code:

Edite `~/.ssh/config`:

```ssh
Host servidor
    HostName 100.64.0.1
    User kelvin
    ForwardAgent yes
```

Agora basta clicar em "servidor" na lista de hosts do VS Code.

## Opção 2: code-server (VS Code no navegador)

### Instalar no servidor:

```bash
curl -fsSL https://code-server.dev/install.sh | sh
```

### Configurar:

```bash
# Editar config
mkdir -p ~/.config/code-server
cat > ~/.config/code-server/config.yaml << EOF
bind-addr: 0.0.0.0:8080
auth: password
password: sua-senha-segura
cert: false
EOF
```

### Iniciar:

```bash
code-server
```

### Acessar:

- Via Tailscale: `http://100.x.x.x:8080`
- Via Cloudflare Tunnel: Criar tunnel para porta 8080

## Opção 3: GitHub Codespaces

Se o repositório estiver no GitHub, pode usar Codespaces para desenvolvimento na nuvem do GitHub (não usa seu servidor).

## Extensões Úteis para Desenvolvimento Remoto

- **Remote - SSH**: Conexão SSH
- **Remote - Tunnels**: Tunnels do VS Code
- **Continue**: IA assistente (conecta com Ollama local)
- **GitHub Copilot**: Se tiver assinatura

