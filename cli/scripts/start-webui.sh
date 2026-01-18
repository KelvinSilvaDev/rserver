#!/bin/bash
# Script para iniciar Open WebUI

cd "$(dirname "$0")/../.."

# Determinar URL do Ollama para o container Docker
WSL_HOST_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "")
if [ -n "$WSL_HOST_IP" ]; then
    OLLAMA_URL="http://$WSL_HOST_IP:11434"
else
    DOCKER_GATEWAY_IP=$(docker network inspect bridge --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' 2>/dev/null || echo "172.17.0.1")
    OLLAMA_URL="http://$DOCKER_GATEWAY_IP:11434"
fi

# Verificar se container já existe e está rodando
if docker ps --format '{{.Names}}' | grep -q "^open-webui$"; then
    exit 0
fi

# Verificar se container existe mas está parado
if docker ps -a --format '{{.Names}}' | grep -q "^open-webui$"; then
    docker start open-webui >/dev/null 2>&1
    sleep 2
    exit 0
fi

# Criar novo container
docker run -d \
    --name open-webui \
    -p 3000:8080 \
    --restart always \
    --add-host=host.docker.internal:host-gateway \
    -e OLLAMA_BASE_URL="$OLLAMA_URL" \
    -v open-webui:/app/backend/data \
    ghcr.io/open-webui/open-webui:latest >/dev/null 2>&1

sleep 3
