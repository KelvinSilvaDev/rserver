#!/bin/bash

# Script para instalar o ComfyUI Manager (permite gerenciar modelos e nodes via web)

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}📦 Instalando ComfyUI Manager...${NC}"

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${RED}❌ Container ComfyUI não está rodando${NC}"
    echo -e "${YELLOW}   Execute: ./start-server.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}   Instalando ComfyUI Manager no container...${NC}"

# Instalar ComfyUI Manager
docker exec comfyui bash -c "
    cd /app/ComfyUI/custom_nodes && \
    if [ ! -d 'ComfyUI-Manager' ]; then
        git clone https://github.com/ltdrdata/ComfyUI-Manager.git
        echo -e '${GREEN}✅ ComfyUI Manager instalado${NC}'
    else
        echo -e '${YELLOW}   ComfyUI Manager já está instalado, atualizando...${NC}'
        cd ComfyUI-Manager && git pull
    fi
"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ ComfyUI Manager instalado com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Próximos passos:${NC}"
    echo "   1. Reinicie o ComfyUI: docker restart comfyui"
    echo "   2. Acesse a interface web do ComfyUI"
    echo "   3. Você verá um novo menu 'Manager' que permite:"
    echo "      - Instalar custom nodes com um clique"
    echo "      - Baixar modelos diretamente"
    echo "      - Atualizar nodes instalados"
    echo ""
    echo -e "${YELLOW}💡 Dica: Após reiniciar, o Manager aparecerá na interface web${NC}"
else
    echo -e "${RED}❌ Erro ao instalar ComfyUI Manager${NC}"
    exit 1
fi

