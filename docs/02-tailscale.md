# 🌐 Tailscale VPN

## O que é Tailscale?

Tailscale cria uma rede privada (VPN mesh) entre seus dispositivos. Cada dispositivo recebe um IP fixo (100.x.x.x) e pode se conectar diretamente aos outros, mesmo atrás de NAT/firewall.

## Vantagens

- ✅ Conexão direta (sem servidor intermediário)
- ✅ IP fixo para cada dispositivo
- ✅ Funciona atrás de qualquer firewall
- ✅ Criptografia end-to-end
- ✅ Grátis para uso pessoal (até 100 dispositivos)

## Instalação

### No Servidor (WSL)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

### No Notebook (Linux/Mac/Windows)

- **Linux**: `curl -fsSL https://tailscale.com/install.sh | sh`
- **Mac**: `brew install tailscale`
- **Windows**: Baixe de https://tailscale.com/download

## Conectar

```bash
sudo tailscale up
```

Abrirá uma URL para autenticação. Faça login com Google/Microsoft/GitHub.

## Ver Dispositivos

```bash
tailscale status
```

Exemplo de saída:
```
100.64.0.1    servidor-wsl    kelvin@     linux   -
100.64.0.2    notebook        kelvin@     linux   -
```

## Usar

Depois de conectado, basta usar o IP do Tailscale:

```bash
# SSH
ssh kelvin@100.64.0.1

# Acessar serviços
curl http://100.64.0.1:11434/api/tags  # Ollama
```

## Compartilhar com outros

No painel https://login.tailscale.com/admin você pode:
- Adicionar outros usuários
- Compartilhar dispositivos específicos
- Configurar ACLs (controle de acesso)

