#!/bin/bash

# Script para limpar arquivos vazios (tamanho 0) dos modelos

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🧹 Limpando arquivos vazios dos modelos...${NC}"

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${RED}❌ Container ComfyUI não está rodando${NC}"
    exit 1
fi

# Encontrar e remover arquivos vazios
EMPTY_FILES=$(docker exec comfyui bash -c "find /app/ComfyUI/models -type f -size 0 -name '*.safetensors' -o -name '*.ckpt' -o -name '*.pt' 2>/dev/null" | wc -l)

if [ "$EMPTY_FILES" -gt 0 ]; then
    echo -e "${YELLOW}   Encontrados $EMPTY_FILES arquivo(s) vazio(s)${NC}"
    docker exec comfyui bash -c "find /app/ComfyUI/models -type f -size 0 \( -name '*.safetensors' -o -name '*.ckpt' -o -name '*.pt' \) -delete 2>/dev/null"
    echo -e "${GREEN}✅ Arquivos vazios removidos${NC}"
else
    echo -e "${GREEN}✅ Nenhum arquivo vazio encontrado${NC}"
fi

