#!/bin/bash

# Script para instalar custom nodes do ComfyUI

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}❌ Uso: $0 <url_do_repositorio> [nome_do_node]${NC}"
    echo ""
    echo -e "${YELLOW}Exemplos:${NC}"
    echo "  $0 https://github.com/ltdrdata/ComfyUI-Manager.git"
    echo "  $0 https://github.com/WASasquatch/was-node-suite-comfyui.git was-node-suite"
    echo "  $0 https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git"
    echo ""
    exit 1
fi

REPO_URL=$1
NODE_NAME=$2

# Se não forneceu nome, extrair do URL
if [ -z "$NODE_NAME" ]; then
    NODE_NAME=$(basename "$REPO_URL" .git)
fi

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${RED}❌ Container ComfyUI não está rodando${NC}"
    echo -e "${YELLOW}   Execute: ./start-server.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Instalando custom node...${NC}"
echo -e "${BLUE}   Repositório: $REPO_URL${NC}"
echo -e "${BLUE}   Nome: $NODE_NAME${NC}"

# Instalar node
docker exec comfyui bash -c "
    cd /app/ComfyUI/custom_nodes && \
    if [ -d '$NODE_NAME' ]; then
        echo -e '${YELLOW}   Node já existe, atualizando...${NC}'
        cd '$NODE_NAME' && git pull
    else
        git clone '$REPO_URL' '$NODE_NAME'
    fi && \
    echo -e '${GREEN}✅ Node instalado${NC}'
"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Custom node instalado com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Próximos passos:${NC}"
    echo "   1. Reinicie o ComfyUI: docker restart comfyui"
    echo "   2. O node estará disponível na interface web"
    echo ""
    echo -e "${YELLOW}💡 Dica: Alguns nodes podem precisar de dependências adicionais${NC}"
    echo -e "${YELLOW}   Verifique a documentação do node para mais informações${NC}"
else
    echo -e "${RED}❌ Erro ao instalar custom node${NC}"
    exit 1
fi

