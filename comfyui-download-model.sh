#!/bin/bash

# Script para baixar modelos do ComfyUI

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}❌ Uso: $0 <tipo> <nome_do_modelo> [url]${NC}"
    echo ""
    echo -e "${YELLOW}Tipos disponíveis:${NC}"
    echo "  checkpoint  - Modelos principais (.safetensors, .ckpt)"
    echo "  vae         - Modelos VAE"
    echo "  lora        - LoRA models"
    echo "  controlnet  - ControlNet models"
    echo "  clip        - CLIP models"
    echo "  embedding   - Textual inversions"
    echo "  upscale     - Modelos de upscale"
    echo ""
    echo -e "${YELLOW}Exemplos:${NC}"
    echo "  $0 checkpoint realisticVisionV60B1_v60B1.safetensors https://huggingface.co/..."
    echo "  $0 lora my-lora.safetensors https://civitai.com/..."
    echo ""
    exit 1
fi

TYPE=$1
MODEL_NAME=$2
URL=$3

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${RED}❌ Container ComfyUI não está rodando${NC}"
    echo -e "${YELLOW}   Execute: ./start-server.sh${NC}"
    exit 1
fi

# Mapear tipo para diretório
case $TYPE in
    checkpoint)
        DIR="checkpoints"
        ;;
    vae)
        DIR="vae"
        ;;
    lora)
        DIR="loras"
        ;;
    controlnet)
        DIR="controlnet"
        ;;
    clip)
        DIR="clip"
        ;;
    embedding)
        DIR="embeddings"
        ;;
    upscale)
        DIR="upscale_models"
        ;;
    *)
        echo -e "${RED}❌ Tipo inválido: $TYPE${NC}"
        exit 1
        ;;
esac

echo -e "${YELLOW}📥 Baixando modelo...${NC}"
echo -e "${BLUE}   Tipo: $TYPE${NC}"
echo -e "${BLUE}   Nome: $MODEL_NAME${NC}"
echo -e "${BLUE}   Diretório: models/$DIR${NC}"

# Baixar modelo
if [ -n "$URL" ]; then
    echo -e "${YELLOW}   Baixando de: $URL${NC}"
    docker exec comfyui bash -c "
        cd /app/ComfyUI/models/$DIR && \
        wget -O '$MODEL_NAME' '$URL' && \
        echo -e '${GREEN}✅ Modelo baixado com sucesso${NC}'
    "
else
    echo -e "${YELLOW}   ⚠️  URL não fornecida. Você pode baixar manualmente:${NC}"
    echo ""
    echo -e "${BLUE}   1. Acesse o diretório no Windows:${NC}"
    
    # Tentar descobrir o caminho do bind mount
    MOUNT_PATH=$(docker inspect comfyui --format '{{range .Mounts}}{{if eq .Destination "/app/ComfyUI/models"}}{{.Source}}{{end}}{{end}}' 2>/dev/null)
    
    if [ -n "$MOUNT_PATH" ] && [ -d "$MOUNT_PATH" ]; then
        FULL_PATH="$MOUNT_PATH/$DIR"
        # Converter para caminho Windows se for /mnt/c/
        if [[ "$FULL_PATH" == /mnt/c/* ]]; then
            WIN_PATH="C:${FULL_PATH#/mnt/c}" | tr '/' '\\'
            echo -e "${GREEN}      Windows: $WIN_PATH${NC}"
        fi
        echo -e "${GREEN}      WSL: $FULL_PATH${NC}"
    else
        echo -e "${YELLOW}      (Usando volumes Docker - verifique com: docker volume inspect comfyui-models)${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}   2. Baixe o modelo '$MODEL_NAME' e coloque em: models/$DIR/${NC}"
    echo -e "${BLUE}   3. Reinicie o container: docker restart comfyui${NC}"
    echo ""
    echo -e "${YELLOW}💡 Dica: Use o ComfyUI Manager para baixar modelos automaticamente!${NC}"
    echo -e "${YELLOW}   Execute: ./comfyui-install-manager.sh${NC}"
fi

