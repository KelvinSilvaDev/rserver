#!/bin/bash

# =============================================================================
# 🔄 Script para iniciar serviços automaticamente quando WSL inicia
# =============================================================================

# Este script deve ser adicionado ao ~/.bashrc ou executado manualmente

echo "🚀 Iniciando serviços do servidor remoto..."

# 1. SSH
if ! service ssh status &>/dev/null; then
    sudo service ssh start
    echo "✅ SSH iniciado"
fi

# 2. Tailscale
TAILSCALE_IP=""
if command -v tailscale &>/dev/null; then
    if ! tailscale status &>/dev/null; then
        echo "⚠️  Tailscale não conectado. Execute: sudo tailscale up"
    else
        TAILSCALE_IP=$(tailscale ip -4 2>/dev/null)
        echo "✅ Tailscale conectado: $TAILSCALE_IP"
        
        # Configurar Tailscale Serve para Web-UI (porta 3000)
        if sudo tailscale serve --bg --http 80 http://127.0.0.1:3000 2>/dev/null; then
            echo "✅ Tailscale Serve configurado para Web-UI"
        else
            # Pode já estar configurado
            if sudo tailscale serve status 2>/dev/null | grep -q "http://127.0.0.1:3000"; then
                echo "✅ Tailscale Serve já configurado para Web-UI"
            fi
        fi
        
        # Configurar Tailscale Serve para ComfyUI (porta 8188)
        if sudo tailscale serve --bg --http 8188 http://127.0.0.1:8188 2>/dev/null; then
            echo "✅ Tailscale Serve configurado para ComfyUI"
        else
            # Pode já estar configurado
            if sudo tailscale serve status 2>/dev/null | grep -q "http://127.0.0.1:8188"; then
                echo "✅ Tailscale Serve já configurado para ComfyUI"
            fi
        fi
    fi
fi

# 3. Ollama
if command -v ollama &>/dev/null; then
    if systemctl is-active --quiet ollama 2>/dev/null; then
        echo "✅ Ollama já rodando (systemd)"
    elif ! pgrep -x "ollama" > /dev/null; then
        if systemctl start ollama 2>/dev/null; then
            echo "✅ Ollama iniciado (systemd)"
        else
            nohup ollama serve > ~/remote-server/logs/ollama.log 2>&1 &
            echo "✅ Ollama iniciado"
        fi
    else
        echo "✅ Ollama já rodando"
    fi
fi

# 3.5. Web-UI (Open WebUI)
if command -v docker &>/dev/null; then
    if docker ps --format '{{.Names}}' | grep -q "^open-webui$"; then
        echo "✅ Web-UI já está rodando"
    else
        # Container não está rodando, iniciar
        echo "🚀 Iniciando container open-webui..."
        
        # Usar IP do host WSL para acessar Ollama (funciona melhor no WSL2)
        WSL_HOST_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "")
        if [ -n "$WSL_HOST_IP" ]; then
            OLLAMA_URL="http://$WSL_HOST_IP:11434"
        else
            # Fallback: usar gateway do Docker
            DOCKER_GATEWAY_IP=$(docker network inspect bridge --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' 2>/dev/null || echo "172.17.0.1")
            OLLAMA_URL="http://$DOCKER_GATEWAY_IP:11434"
        fi
        
        if docker run -d \
            --name open-webui \
            -p 3000:8080 \
            --restart always \
            --add-host=host.docker.internal:host-gateway \
            -e OLLAMA_BASE_URL="$OLLAMA_URL" \
            -v open-webui:/app/backend/data \
            ghcr.io/open-webui/open-webui:latest 2>/dev/null; then
            sleep 3
            echo "✅ Web-UI iniciado com OLLAMA_BASE_URL=$OLLAMA_URL"
        else
            echo "⚠️  Erro ao iniciar container open-webui"
        fi
    fi
fi

# 3.6. ComfyUI
if command -v docker &>/dev/null; then
    if docker ps --format '{{.Names}}' | grep -qi "comfyui"; then
        echo "✅ ComfyUI (Docker) já está rodando"
    elif curl -s --max-time 2 http://127.0.0.1:8188 >/dev/null 2>&1; then
        echo "✅ ComfyUI já está rodando e acessível"
    elif docker ps -a --format '{{.Names}}' | grep -qi "comfyui"; then
        echo "🔄 Reiniciando container ComfyUI..."
        docker start comfyui >/dev/null 2>&1
        sleep 3
        echo "✅ ComfyUI reiniciado"
    else
        echo "🚀 Iniciando ComfyUI via Docker..."
        # Usar imagem local do ComfyUI (sem autenticação)
        # Se não existir, construir primeiro
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^comfyui:local$"; then
            echo "   Construindo imagem local do ComfyUI (pode levar alguns minutos)..."
            cd "$SCRIPT_DIR/docker/comfyui" && \
            docker build -t comfyui:local . >/dev/null 2>&1 && \
            cd - >/dev/null
        fi
        
        if docker run -d \
            --name comfyui \
            -p 127.0.0.1:8188:8188 \
            --restart always \
            --gpus all \
            -v comfyui-models:/app/ComfyUI/models \
            -v comfyui-output:/app/ComfyUI/output \
            -v comfyui-input:/app/ComfyUI/input \
            comfyui:local 2>/dev/null; then
            sleep 5
            echo "✅ ComfyUI iniciado"
        else
            echo "⚠️  Erro ao iniciar ComfyUI"
        fi
    fi
fi

echo ""
echo "📍 Para ver status completo: ~/remote-server/status.sh"

