#!/bin/bash

# Script para listar modelos instalados no ComfyUI

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${RED}❌ Container ComfyUI não está rodando${NC}"
    echo -e "${YELLOW}   Execute: ./start-server.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Modelos instalados no ComfyUI:${NC}"
echo ""

# Listar modelos por tipo
for TYPE in checkpoints vae loras controlnet clip embeddings upscale_models; do
    COUNT=$(docker exec comfyui bash -c "ls -1 /app/ComfyUI/models/$TYPE/*.{safetensors,ckpt,pt,bin} 2>/dev/null | wc -l" | tr -d ' ')
    if [ "$COUNT" -gt 0 ]; then
        echo -e "${GREEN}📦 $TYPE: $COUNT modelo(s)${NC}"
        docker exec comfyui bash -c "ls -1h /app/ComfyUI/models/$TYPE/*.{safetensors,ckpt,pt,bin} 2>/dev/null | xargs -n1 basename | head -10"
        if [ "$COUNT" -gt 10 ]; then
            echo -e "${YELLOW}   ... e mais $((COUNT - 10)) modelo(s)${NC}"
        fi
        echo ""
    fi
done

# Listar custom nodes
echo -e "${YELLOW}📦 Custom Nodes instalados:${NC}"
NODE_COUNT=$(docker exec comfyui bash -c "ls -1d /app/ComfyUI/custom_nodes/*/ 2>/dev/null | wc -l" | tr -d ' ')
if [ "$NODE_COUNT" -gt 0 ]; then
    docker exec comfyui bash -c "ls -1d /app/ComfyUI/custom_nodes/*/ 2>/dev/null | xargs -n1 basename"
else
    echo -e "${YELLOW}   Nenhum custom node instalado${NC}"
fi

