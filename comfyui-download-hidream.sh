#!/bin/bash

# Script para baixar modelos HIDream necessários para o workflow

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}📥 Baixando modelos HIDream necessários...${NC}"

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${RED}❌ Container ComfyUI não está rodando${NC}"
    echo -e "${YELLOW}   Execute: ./start-server.sh${NC}"
    exit 1
fi

# Lista de modelos necessários baseado no erro
declare -A MODELS=(
    # CLIP models
    ["clip/clip_l_hidream.safetensors"]="https://huggingface.co/black-forest-labs/HIDream/resolve/main/clip/clip_l_hidream.safetensors"
    ["clip/clip_g_hidream.safetensors"]="https://huggingface.co/black-forest-labs/HIDream/resolve/main/clip/clip_g_hidream.safetensors"
    ["clip/hidream_i1_fast_bf16.safetensors"]="https://huggingface.co/black-forest-labs/HIDream/resolve/main/clip/hidream_i1_fast_bf16.safetensors"
    # t5xxl precisa estar em subdiretório t5/ conforme o erro mostra
    ["clip/t5/t5xxl_fp8_e4m3fn_scaled.safetensors"]="https://huggingface.co/black-forest-labs/HIDream/resolve/main/clip/t5xxl_fp8_e4m3fn_scaled.safetensors"
    ["clip/llama_3.1_8b_instruct_fp8_scaled.safetensors"]="https://huggingface.co/black-forest-labs/HIDream/resolve/main/clip/llama_3.1_8b_instruct_fp8_scaled.safetensors"
    
    # UNET
    ["unet/hidream_i1_full_fp8.safetensors"]="https://huggingface.co/black-forest-labs/HIDream/resolve/main/unet/hidream_i1_full_fp8.safetensors"
)

MODELS_PATH="/app/ComfyUI/models"
SUCCESS=0
FAILED=0

for MODEL_PATH in "${!MODELS[@]}"; do
    URL="${MODELS[$MODEL_PATH]}"
    FILENAME=$(basename "$MODEL_PATH")
    DIR=$(dirname "$MODEL_PATH")
    
    echo ""
    echo -e "${BLUE}📦 Baixando: $FILENAME${NC}"
    echo -e "${YELLOW}   Para: models/$MODEL_PATH${NC}"
    
    # Verificar se já existe
    if docker exec comfyui test -f "$MODELS_PATH/$MODEL_PATH" 2>/dev/null; then
        echo -e "${GREEN}   ✅ Já existe, pulando...${NC}"
        ((SUCCESS++))
        continue
    fi
    
    # Criar diretório se não existir
    docker exec comfyui bash -c "mkdir -p $MODELS_PATH/$DIR" 2>/dev/null
    
    # Baixar
    if docker exec comfyui bash -c "
        cd $MODELS_PATH/$DIR && \
        wget --progress=bar:force -O '$FILENAME' '$URL' 2>&1 | tail -1 && \
        test -f '$FILENAME'
    "; then
        SIZE=$(docker exec comfyui bash -c "du -h $MODELS_PATH/$MODEL_PATH 2>/dev/null | cut -f1" | tr -d '\r')
        echo -e "${GREEN}   ✅ Baixado! Tamanho: $SIZE${NC}"
        ((SUCCESS++))
    else
        echo -e "${RED}   ❌ Erro ao baixar${NC}"
        ((FAILED++))
    fi
done

echo ""
echo -e "${YELLOW}===========================================${NC}"
echo -e "${GREEN}✅ Sucesso: $SUCCESS modelo(s)${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Falhas: $FAILED modelo(s)${NC}"
fi
echo -e "${YELLOW}===========================================${NC}"

if [ $SUCCESS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}📋 Próximos passos:${NC}"
    echo "   1. Reinicie o ComfyUI: docker restart comfyui"
    echo "   2. Os modelos estarão disponíveis no workflow"
fi

