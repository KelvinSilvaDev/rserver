# 🔐 SSH e Acesso Remoto

## Configuração no WSL

O SSH já vem configurado pelo script de setup. Para verificar:

```bash
sudo service ssh status
```

## Conectar ao Servidor

### Via Tailscale (Recomendado)

```bash
# No notebook/outro PC (depois de instalar Tailscale)
ssh kelvin@100.x.x.x  # IP do Tailscale
```

### Via Cloudflare Tunnel

```bash
# Instalar cloudflared no cliente
curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared

# Conectar
./cloudflared access ssh --hostname <URL-DO-TUNNEL>
```

### Configurar ~/.ssh/config (Cliente)

```ssh
# Conexão via Tailscale
Host servidor
    HostName 100.x.x.x
    User kelvin
    ForwardAgent yes

# Conexão via Cloudflare
Host servidor-cf
    HostName <URL>.trycloudflare.com
    User kelvin
    ProxyCommand cloudflared access ssh --hostname %h
```

## Chaves SSH

### Gerar chave no cliente:

```bash
ssh-keygen -t ed25519 -C "notebook@example.com"
```

### Copiar para o servidor:

```bash
ssh-copy-id kelvin@100.x.x.x
```

## Túnel SSH para portas locais

```bash
# Acessar Ollama do servidor no notebook
ssh -L 11434:localhost:11434 kelvin@100.x.x.x

# Agora http://localhost:11434 no notebook acessa o Ollama do servidor
```

