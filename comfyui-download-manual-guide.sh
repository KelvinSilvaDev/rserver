#!/bin/bash

# Script que mostra instruções para baixar modelos manualmente
# Útil quando o HuggingFace requer autenticação

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}📋 Guia para baixar modelos manualmente${NC}"
echo ""

# Descobrir caminho dos modelos
MOUNT_PATH=$(docker inspect comfyui --format '{{range .Mounts}}{{if eq .Destination "/app/ComfyUI/models"}}{{.Source}}{{end}}{{end}}' 2>/dev/null)

if [ -n "$MOUNT_PATH" ] && [ -d "$MOUNT_PATH" ]; then
    echo -e "${GREEN}✅ Bind mount encontrado!${NC}"
    echo ""
    
    if [[ "$MOUNT_PATH" == /mnt/c/* ]]; then
        WIN_PATH="C:${MOUNT_PATH#/mnt/c}" | tr '/' '\\'
        echo -e "${BLUE}📍 Caminho no Windows:${NC}"
        echo -e "${GREEN}   $WIN_PATH${NC}"
        echo ""
        echo -e "${BLUE}📍 Caminho no WSL:${NC}"
        echo -e "${GREEN}   $MOUNT_PATH${NC}"
    else
        echo -e "${BLUE}📍 Caminho:${NC}"
        echo -e "${GREEN}   $MOUNT_PATH${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}📥 Modelos necessários:${NC}"
    echo ""
    echo -e "${BLUE}1. VAE FLUX.1:${NC}"
    echo "   URL: https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/vae/ae.safetensors"
    echo "   Salvar em: $MOUNT_PATH/vae/ae.safetensors"
    echo ""
    echo -e "${BLUE}2. Modelos HIDream:${NC}"
    echo "   Base URL: https://huggingface.co/black-forest-labs/HIDream/tree/main"
    echo ""
    echo "   CLIP models:"
    echo "   - clip_l_hidream.safetensors → $MOUNT_PATH/clip/"
    echo "   - clip_g_hidream.safetensors → $MOUNT_PATH/clip/"
    echo "   - hidream_i1_fast_bf16.safetensors → $MOUNT_PATH/clip/"
    echo "   - llama_3.1_8b_instruct_fp8_scaled.safetensors → $MOUNT_PATH/clip/"
    echo "   - t5xxl_fp8_e4m3fn_scaled.safetensors → $MOUNT_PATH/clip/t5/"
    echo ""
    echo "   UNET:"
    echo "   - hidream_i1_full_fp8.safetensors → $MOUNT_PATH/unet/"
    echo ""
    echo -e "${YELLOW}💡 Dica:${NC}"
    echo "   - Use o navegador para acessar o HuggingFace"
    echo "   - Clique em 'Files and versions' no repositório"
    echo "   - Baixe os arquivos .safetensors"
    echo "   - Coloque nos diretórios corretos acima"
    echo "   - Reinicie: docker restart comfyui"
    
else
    echo -e "${YELLOW}⚠️  Usando volumes Docker${NC}"
    echo ""
    echo -e "${BLUE}Para acessar os volumes:${NC}"
    echo "   docker exec -it comfyui bash"
    echo "   cd /app/ComfyUI/models"
    echo ""
    echo -e "${YELLOW}Ou copie os arquivos:${NC}"
    echo "   docker cp arquivo.safetensors comfyui:/app/ComfyUI/models/vae/"
fi

