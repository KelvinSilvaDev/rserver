# 🖥️ Desktop Remoto (RDP)

## Acessar o Windows Host

Como você está usando WSL, o Windows ainda está rodando. Você pode acessar o desktop Windows remotamente.

## Habilitar RDP no Windows

1. Pressione `Win + I` → **Sistema** → **Área de Trabalho Remota**
2. Ative **Área de Trabalho Remota**
3. Anote o nome do PC

## Conectar via Tailscale

Depois que o Windows também tiver Tailscale instalado:

1. Instale Tailscale no Windows: https://tailscale.com/download
2. O Windows terá um IP Tailscale (ex: 100.64.0.3)
3. Do notebook, conecte via RDP:

### Linux (Remmina)

```bash
sudo apt install remmina
remmina
# Adicionar conexão RDP para 100.64.0.3
```

### Mac

Use o app **Microsoft Remote Desktop** da App Store.

### Windows

```
mstsc /v:100.64.0.3
```

## Alternativa: Parsec (Gaming/Baixa Latência)

Se precisar de baixa latência (para usar a GPU, jogos, etc):

1. Instale Parsec no Windows: https://parsec.app
2. Instale no notebook também
3. Conecte via conta Parsec

**Vantagens do Parsec:**
- Usa GPU para encoding
- Latência muito baixa
- Ideal para trabalho gráfico

## Alternativa: RustDesk (Open Source)

```bash
# No Windows e no notebook
# Baixe de https://rustdesk.com
```

## Tunnel RDP via Cloudflare

```bash
# No WSL
cloudflared tunnel --url rdp://localhost:3389

# Ou acessar diretamente o Windows se tiver Tailscale
```

## Dica: X11 Forwarding (Apps Linux no Notebook)

```bash
# Conectar com X11 forwarding
ssh -X kelvin@100.x.x.x

# Agora pode rodar apps gráficos do servidor
firefox &  # Abre no seu notebook
```

