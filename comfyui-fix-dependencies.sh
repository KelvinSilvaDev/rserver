#!/bin/bash

# Script para corrigir dependências do ComfyUI após instalação do huggingface-cli

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Corrigindo dependências do ComfyUI...${NC}"

# Parar o container
echo -e "${YELLOW}   Parando container...${NC}"
docker stop comfyui 2>/dev/null

# Aguardar um pouco
sleep 2

# Criar um container temporário para corrigir dependências
echo -e "${YELLOW}   Corrigindo dependências...${NC}"
docker run --rm \
    --volumes-from comfyui \
    comfyui:local \
    bash -c "
        pip uninstall -y huggingface-hub 2>/dev/null || true && \
        pip install 'huggingface-hub>=0.34.0,<1.0' --quiet && \
        echo '✅ Dependências corrigidas'
    " 2>&1 | tail -3

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dependências corrigidas!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Reiniciando ComfyUI...${NC}"
    docker start comfyui
    sleep 8
    
    # Verificar se está funcionando
    if curl -s --max-time 5 http://127.0.0.1:8188 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ ComfyUI está respondendo!${NC}"
    else
        echo -e "${YELLOW}⚠️  ComfyUI ainda está iniciando...${NC}"
        echo -e "${YELLOW}   Aguarde alguns segundos e verifique: docker logs comfyui${NC}"
    fi
else
    echo -e "${RED}❌ Erro ao corrigir dependências${NC}"
    exit 1
fi

