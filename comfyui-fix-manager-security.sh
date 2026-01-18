#!/bin/bash

# Script para ajustar configuração de segurança do ComfyUI Manager

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Ajustando configuração de segurança do ComfyUI Manager...${NC}"

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${RED}❌ Container ComfyUI não está rodando${NC}"
    echo -e "${YELLOW}   Execute: ./start-server.sh${NC}"
    exit 1
fi

# Verificar se o Manager está instalado
if ! docker exec comfyui test -d /app/ComfyUI/custom_nodes/ComfyUI-Manager 2>/dev/null; then
    echo -e "${RED}❌ ComfyUI Manager não está instalado${NC}"
    echo -e "${YELLOW}   Execute: ./comfyui-install-manager.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}   Configurando permissões de segurança...${NC}"

# Criar ou atualizar arquivo de configuração
# O Manager usa variáveis de ambiente ou arquivo .env
docker exec comfyui bash -c "
    cd /app/ComfyUI && \
    # Criar arquivo .env se não existir
    if [ ! -f .env ]; then
        touch .env
    fi && \
    # Adicionar configurações de segurança
    if ! grep -q 'COMFYUI_MANAGER_SECURITY_LEVEL' .env; then
        echo 'COMFYUI_MANAGER_SECURITY_LEVEL=0' >> .env
        echo -e '${GREEN}✅ Configuração de segurança adicionada${NC}'
    else
        sed -i 's/COMFYUI_MANAGER_SECURITY_LEVEL=.*/COMFYUI_MANAGER_SECURITY_LEVEL=0/' .env
        echo -e '${GREEN}✅ Configuração de segurança atualizada${NC}'
    fi && \
    # Também criar config.yaml no Manager (método alternativo)
    mkdir -p custom_nodes/ComfyUI-Manager && \
    cat > custom_nodes/ComfyUI-Manager/config.yaml << 'EOF'
security:
  allow_model_download: true
  allow_node_install: true
  allow_git_install: true
  security_level: 0
EOF
    echo -e '${GREEN}✅ Arquivo config.yaml criado${NC}'
"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Configuração de segurança ajustada!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Próximos passos:${NC}"
    echo "   1. Reinicie o ComfyUI: docker restart comfyui"
    echo "   2. Tente instalar o modelo novamente pelo Manager"
    echo ""
    echo -e "${YELLOW}⚠️  Nota: O nível de segurança foi definido como 0 (sem restrições)${NC}"
    echo -e "${YELLOW}   Isso permite instalar qualquer modelo/node. Use com cuidado!${NC}"
else
    echo -e "${RED}❌ Erro ao configurar segurança${NC}"
    exit 1
fi

