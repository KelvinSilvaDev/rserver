#!/bin/bash

# Script para instalar huggingface-cli no container ComfyUI
# Isso permite baixar modelos do HuggingFace com autenticação

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}📦 Instalando huggingface-cli no ComfyUI...${NC}"

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${RED}❌ Container ComfyUI não está rodando${NC}"
    echo -e "${YELLOW}   Execute: ./start-server.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}   Instalando huggingface-hub...${NC}"

# Instalar huggingface-cli
docker exec comfyui bash -c "
    pip install --upgrade huggingface-hub && \
    echo -e '${GREEN}✅ huggingface-cli instalado${NC}'
"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ huggingface-cli instalado com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Agora você pode:${NC}"
    echo "   1. Baixar modelos usando: ./comfyui-download-flux-vae.sh"
    echo "   2. Ou usar o Manager após reiniciar: docker restart comfyui"
    echo ""
    echo -e "${YELLOW}💡 Nota: Alguns modelos podem ainda precisar de token do HuggingFace${NC}"
    echo -e "${YELLOW}   Configure com: huggingface-cli login${NC}"
else
    echo -e "${RED}❌ Erro ao instalar huggingface-cli${NC}"
    exit 1
fi

