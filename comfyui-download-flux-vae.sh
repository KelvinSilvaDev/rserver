#!/bin/bash

# Script para baixar o VAE do FLUX.1

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

VAE_NAME="ae.safetensors"
# URL do VAE FLUX.1 (pode ser FLUX.1-dev ou FLUX.1-schnell)
VAE_URL="https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/vae/ae.safetensors"
VAE_URL_ALT="https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/vae/ae.safetensors"
VAE_DIR="vae"

echo -e "${YELLOW}📥 Baixando VAE FLUX.1...${NC}"

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${RED}❌ Container ComfyUI não está rodando${NC}"
    echo -e "${YELLOW}   Execute: ./start-server.sh${NC}"
    exit 1
fi

# Descobrir onde está o diretório de modelos
MODELS_PATH="/app/ComfyUI/models"

# Verificar se já existe
if docker exec comfyui test -f "$MODELS_PATH/$VAE_DIR/$VAE_NAME" 2>/dev/null; then
    echo -e "${YELLOW}   ⚠️  O arquivo já existe: $VAE_DIR/$VAE_NAME${NC}"
    read -p "   Deseja baixar novamente? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${GREEN}✅ Cancelado${NC}"
        exit 0
    fi
fi

echo -e "${BLUE}   URL: $VAE_URL${NC}"
echo -e "${BLUE}   Destino: models/$VAE_DIR/$VAE_NAME${NC}"
echo ""
echo -e "${YELLOW}   Baixando (335MB, pode levar alguns minutos)...${NC}"

# Tentar baixar usando huggingface-cli (se disponível) ou wget com headers
echo -e "${YELLOW}   Tentando baixar de: $VAE_URL${NC}"

# Verificar se huggingface-cli está disponível
if docker exec comfyui bash -c "command -v huggingface-cli >/dev/null 2>&1"; then
    echo -e "${YELLOW}   Usando huggingface-cli...${NC}"
    docker exec comfyui bash -c "
        cd $MODELS_PATH/$VAE_DIR && \
        huggingface-cli download black-forest-labs/FLUX.1-dev --local-dir . --include 'vae/ae.safetensors' && \
        mv vae/ae.safetensors ae.safetensors 2>/dev/null || true && \
        test -f '$VAE_NAME' && test -s '$VAE_NAME'
    "
else
    # Tentar com wget usando headers que simulam um navegador
    echo -e "${YELLOW}   Usando wget com headers customizados...${NC}"
    docker exec comfyui bash -c "
        cd $MODELS_PATH/$VAE_DIR && \
        wget --header='User-Agent: Mozilla/5.0' --header='Accept: */*' \
             --progress=bar:force -O '$VAE_NAME' '$VAE_URL' 2>&1 | tail -3 && \
        test -f '$VAE_NAME' && test -s '$VAE_NAME'
    "
fi

# Verificar se o download funcionou
if docker exec comfyui bash -c "test -f $MODELS_PATH/$VAE_DIR/$VAE_NAME && test -s $MODELS_PATH/$VAE_DIR/$VAE_NAME"; then
    SIZE=$(docker exec comfyui bash -c "du -h $MODELS_PATH/$VAE_DIR/$VAE_NAME 2>/dev/null | cut -f1" | tr -d '\r')
    echo -e "${GREEN}✅ VAE baixado com sucesso! Tamanho: $SIZE${NC}"
else
    echo -e "${YELLOW}   ⚠️  Primeira tentativa falhou, tentando URL alternativa...${NC}"
    echo -e "${YELLOW}   Tentando baixar de: $VAE_URL_ALT${NC}"
    
    if docker exec comfyui bash -c "
        cd $MODELS_PATH/$VAE_DIR && \
        wget --header='User-Agent: Mozilla/5.0' --header='Accept: */*' \
             --progress=bar:force -O '$VAE_NAME' '$VAE_URL_ALT' 2>&1 | tail -3 && \
        test -f '$VAE_NAME' && test -s '$VAE_NAME'
    "; then
        SIZE=$(docker exec comfyui bash -c "du -h $MODELS_PATH/$VAE_DIR/$VAE_NAME 2>/dev/null | cut -f1" | tr -d '\r')
        echo -e "${GREEN}✅ VAE baixado com sucesso! Tamanho: $SIZE${NC}"
    else
        echo -e "${RED}❌ Erro ao baixar VAE de ambas as URLs${NC}"
        echo ""
        echo -e "${YELLOW}💡 O HuggingFace pode estar exigindo autenticação.${NC}"
        echo -e "${YELLOW}   Tente baixar manualmente ou use o Manager após reiniciar.${NC}"
        exit 1
    fi
fi

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ VAE FLUX.1 instalado com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Próximos passos:${NC}"
    echo "   1. Reinicie o ComfyUI: docker restart comfyui"
    echo "   2. O modelo estará disponível como 'ae.safetensors' no VAE Loader"
    echo ""
else
    echo -e "${RED}❌ Erro ao baixar VAE${NC}"
    echo ""
    echo -e "${YELLOW}💡 Alternativa: Baixe manualmente${NC}"
    
    # Tentar descobrir o caminho do bind mount
    MOUNT_PATH=$(docker inspect comfyui --format '{{range .Mounts}}{{if eq .Destination "/app/ComfyUI/models"}}{{.Source}}{{end}}{{end}}' 2>/dev/null)
    
    if [ -n "$MOUNT_PATH" ] && [ -d "$MOUNT_PATH" ]; then
        FULL_PATH="$MOUNT_PATH/$VAE_DIR"
        if [[ "$FULL_PATH" == /mnt/c/* ]]; then
            WIN_PATH="C:${FULL_PATH#/mnt/c}" | tr '/' '\\'
            echo -e "${BLUE}   1. Baixe de: $VAE_URL${NC}"
            echo -e "${BLUE}   2. Salve em: $WIN_PATH\\$VAE_NAME${NC}"
            echo -e "${BLUE}   3. Ou em WSL: $FULL_PATH/$VAE_NAME${NC}"
        else
            echo -e "${BLUE}   1. Baixe de: $VAE_URL${NC}"
            echo -e "${BLUE}   2. Salve em: $FULL_PATH/$VAE_NAME${NC}"
        fi
        echo -e "${BLUE}   4. Reinicie: docker restart comfyui${NC}"
    else
        echo -e "${BLUE}   1. Baixe de: $VAE_URL${NC}"
        echo -e "${BLUE}   2. Coloque em: models/$VAE_DIR/$VAE_NAME${NC}"
        echo -e "${BLUE}   3. Reinicie: docker restart comfyui${NC}"
    fi
    exit 1
fi

