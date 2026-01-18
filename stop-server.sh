#!/bin/bash

# =============================================================================
# 🛑 PARAR SERVIDOR REMOTO
# =============================================================================

echo "🛑 Parando servidor remoto..."

# Parar tunnels
pkill -f "cloudflared tunnel" 2>/dev/null && echo "✅ Tunnels parados"

# Parar Ollama
pkill -f "ollama serve" 2>/dev/null && echo "✅ Ollama parado"

# Parar Tailscale Serve
if sudo tailscale serve --http=80 off 2>/dev/null; then
    echo "✅ Tailscale Serve parado"
fi

# Parar Nginx (opcional - pode deixar rodando)
# sudo systemctl stop nginx 2>/dev/null && echo "✅ Nginx parado"

# SSH continua rodando (não para)
echo "ℹ️  SSH continua rodando"

echo ""
echo "✅ Servidor parado (exceto SSH)"

