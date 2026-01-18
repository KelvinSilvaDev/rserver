#!/bin/bash

# Script simples para migrar dados do ComfyUI
# Uso: ./migrate-comfyui-simple.sh

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

OLD_PATH="/mnt/c/Users/klvml/Downloads/ComfyUI-Easy-Install/ComfyUI-Easy-Install/ComfyUI"

echo -e "${YELLOW}📦 Migração simples de dados do ComfyUI${NC}"
echo ""

# Verificar se o caminho existe
if [ ! -d "$OLD_PATH" ]; then
    echo -e "${YELLOW}⚠️  Caminho não encontrado: $OLD_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Caminho encontrado: $OLD_PATH${NC}"
echo ""

# Verificar se container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${YELLOW}⚠️  Container não está rodando. Iniciando...${NC}"
    docker start comfyui
    sleep 5
fi

# Copiar models (já foi copiado, mas vamos verificar)
if [ -d "$OLD_PATH/models" ]; then
    echo -e "${YELLOW}📋 Copiando Models...${NC}"
    docker cp "$OLD_PATH/models/." comfyui:/app/ComfyUI/models/ 2>&1 | grep -v "^$" | tail -3
    echo -e "${GREEN}✅ Models copiados${NC}"
    echo ""
fi

# Copiar output
if [ -d "$OLD_PATH/output" ]; then
    echo -e "${YELLOW}📋 Copiando Output...${NC}"
    docker cp "$OLD_PATH/output/." comfyui:/app/ComfyUI/output/ 2>&1 | grep -v "^$" | tail -3
    echo -e "${GREEN}✅ Output copiado${NC}"
    echo ""
fi

# Copiar input
if [ -d "$OLD_PATH/input" ]; then
    echo -e "${YELLOW}📋 Copiando Input...${NC}"
    docker cp "$OLD_PATH/input/." comfyui:/app/ComfyUI/input/ 2>&1 | grep -v "^$" | tail -3
    echo -e "${GREEN}✅ Input copiado${NC}"
    echo ""
fi

# Copiar custom_nodes
if [ -d "$OLD_PATH/custom_nodes" ]; then
    echo -e "${YELLOW}📋 Copiando Custom Nodes...${NC}"
    docker cp "$OLD_PATH/custom_nodes/." comfyui:/app/ComfyUI/custom_nodes/ 2>&1 | grep -v "^$" | tail -3
    echo -e "${GREEN}✅ Custom Nodes copiados${NC}"
    echo ""
fi

echo -e "${GREEN}✅ Migração concluída!${NC}"
echo ""
echo -e "${YELLOW}💡 Reinicie o container para ver os dados:${NC}"
echo "   docker restart comfyui"

