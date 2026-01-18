#!/bin/bash

# =============================================================================
# 🔧 CORRIGIR CONEXÕES DO OPEN WEBUI
# =============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Corrigindo conexões do Open WebUI...${NC}"
echo ""

# Verificar se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^open-webui$"; then
    echo -e "${RED}❌ Container open-webui não está rodando${NC}"
    echo -e "${YELLOW}Execute: ./start-server.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Container está rodando${NC}"

# Verificar OLLAMA_BASE_URL
OLLAMA_URL=$(docker inspect open-webui --format '{{range .Config.Env}}{{println .}}{{end}}' | grep "^OLLAMA_BASE_URL=" | cut -d'=' -f2-)
if [ -z "$OLLAMA_URL" ]; then
    # Tentar obter do IP do WSL
    WSL_HOST_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "")
    if [ -n "$WSL_HOST_IP" ]; then
        OLLAMA_URL="http://$WSL_HOST_IP:11434"
    fi
fi
echo -e "${YELLOW}OLLAMA_BASE_URL configurado: $OLLAMA_URL${NC}"

# Testar conectividade
echo -e "${YELLOW}Testando conectividade com Ollama...${NC}"
if docker exec open-webui sh -c "curl -s --max-time 5 $OLLAMA_URL/api/tags" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Container consegue acessar Ollama${NC}"
else
    echo -e "${RED}❌ Container NÃO consegue acessar Ollama${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}==========================================${NC}"
echo -e "${YELLOW}📋 INSTRUÇÕES PARA CORRIGIR:${NC}"
echo -e "${YELLOW}==========================================${NC}"
echo ""
echo "1. Acesse o Open WebUI: http://localhost:3000"
echo ""
echo "2. Clique no ícone de perfil (canto inferior esquerdo)"
echo ""
echo "3. Vá em 'Admin Settings' → 'Connections'"
echo ""
echo "4. Em 'Manage Ollama API Connections':"
echo "   - REMOVA todas as URLs antigas (host.docker.internal, Cloudflare, etc)"
echo "   - ADICIONE apenas: $OLLAMA_URL"
echo "   - Clique em 'Save'"
echo ""
echo "5. Recarregue a página (F5) ou reinicie o container:"
echo "   docker restart open-webui"
echo ""
echo -e "${GREEN}Após isso, os modelos devem aparecer automaticamente!${NC}"
echo ""

