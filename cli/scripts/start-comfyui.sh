#!/bin/bash
# Script para iniciar ComfyUI

cd "$(dirname "$0")/../.."

# Verificar se já está rodando
if docker ps --format '{{.Names}}' | grep -qi "comfyui"; then
    exit 0
fi

# Verificar se está acessível
if curl -s --max-time 2 http://127.0.0.1:8188 >/dev/null 2>&1; then
    exit 0
fi

# Verificar se container existe mas está parado
if docker ps -a --format '{{.Names}}' | grep -qi "comfyui"; then
    docker start comfyui >/dev/null 2>&1
    sleep 3
    exit 0
fi

# Verificar se imagem existe, se não, construir
if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^comfyui:local$"; then
    SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
    cd "$SCRIPT_DIR/docker/comfyui" && \
    docker build -t comfyui:local . >/dev/null 2>&1 && \
    cd - >/dev/null
fi

# Usar bind mounts se disponível
WINDOWS_COMFYUI_PATH="/mnt/c/Users/klvml/Downloads/ComfyUI-Easy-Install/ComfyUI-Easy-Install/ComfyUI"

if [ -d "$WINDOWS_COMFYUI_PATH" ]; then
    MOUNT_MODELS="-v $WINDOWS_COMFYUI_PATH/models:/app/ComfyUI/models"
    MOUNT_OUTPUT="-v $WINDOWS_COMFYUI_PATH/output:/app/ComfyUI/output"
    MOUNT_INPUT="-v $WINDOWS_COMFYUI_PATH/input:/app/ComfyUI/input"
    MOUNT_CUSTOM="-v $WINDOWS_COMFYUI_PATH/custom_nodes:/app/ComfyUI/custom_nodes"
else
    MOUNT_MODELS="-v comfyui-models:/app/ComfyUI/models"
    MOUNT_OUTPUT="-v comfyui-output:/app/ComfyUI/output"
    MOUNT_INPUT="-v comfyui-input:/app/ComfyUI/input"
    MOUNT_CUSTOM=""
fi

# Criar container
docker run -d \
    --name comfyui \
    -p 127.0.0.1:8188:8188 \
    --restart always \
    --gpus all \
    $MOUNT_MODELS \
    $MOUNT_OUTPUT \
    $MOUNT_INPUT \
    $MOUNT_CUSTOM \
    comfyui:local >/dev/null 2>&1

sleep 5
