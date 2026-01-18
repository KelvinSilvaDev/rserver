#!/bin/bash

# =============================================================================
# 🔍 DIAGNÓSTICO - Web-UI e Ollama
# =============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Diagnóstico de Conectividade - Web-UI e Ollama${NC}"
echo ""

# 1. Verificar se Ollama está rodando
echo -e "${YELLOW}1. Verificando Ollama...${NC}"
if systemctl is-active --quiet ollama 2>/dev/null || pgrep -x ollama >/dev/null; then
    echo -e "${GREEN}   ✅ Ollama está rodando${NC}"
    
    # Testar acesso local
    if curl -s --max-time 2 http://localhost:11434/api/tags >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Ollama responde em http://localhost:11434${NC}"
        MODEL_COUNT=$(curl -s http://localhost:11434/api/tags 2>/dev/null | grep -o '"name"' | wc -l)
        echo -e "${GREEN}   ✅ Modelos encontrados: $MODEL_COUNT${NC}"
    else
        echo -e "${RED}   ❌ Ollama não responde em http://localhost:11434${NC}"
    fi
else
    echo -e "${RED}   ❌ Ollama não está rodando${NC}"
    echo -e "${YELLOW}   Execute: sudo systemctl start ollama${NC}"
fi

echo ""

# 2. Verificar container open-webui
echo -e "${YELLOW}2. Verificando container open-webui...${NC}"
if docker ps --format '{{.Names}}' | grep -q "^open-webui$"; then
    echo -e "${GREEN}   ✅ Container open-webui está rodando${NC}"
    
    # Verificar OLLAMA_BASE_URL
    OLLAMA_URL=$(docker inspect open-webui --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | grep "^OLLAMA_BASE_URL=" | cut -d'=' -f2- || echo "não configurado")
    echo -e "${YELLOW}   OLLAMA_BASE_URL: $OLLAMA_URL${NC}"
    
    # Testar conectividade do container
    echo -e "${YELLOW}   Testando conectividade do container com Ollama...${NC}"
    if docker exec open-webui sh -c "curl -s --max-time 3 $OLLAMA_URL/api/tags" >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Container consegue acessar Ollama em $OLLAMA_URL${NC}"
    else
        echo -e "${RED}   ❌ Container NÃO consegue acessar Ollama em $OLLAMA_URL${NC}"
        echo -e "${YELLOW}   Tentando alternativas...${NC}"
        
        # Tentar host.docker.internal
        if docker exec open-webui sh -c "curl -s --max-time 3 http://host.docker.internal:11434/api/tags" >/dev/null 2>&1; then
            echo -e "${GREEN}   ✅ host.docker.internal funciona!${NC}"
            echo -e "${YELLOW}   🔄 Recrie o container com: docker stop open-webui && docker rm open-webui && ./start-server.sh${NC}"
        else
            # Tentar gateway do Docker
            DOCKER_GATEWAY=$(docker network inspect bridge --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' 2>/dev/null || echo "")
            if [ -n "$DOCKER_GATEWAY" ]; then
                if docker exec open-webui sh -c "curl -s --max-time 3 http://$DOCKER_GATEWAY:11434/api/tags" >/dev/null 2>&1; then
                    echo -e "${GREEN}   ✅ Gateway Docker ($DOCKER_GATEWAY) funciona!${NC}"
                    echo -e "${YELLOW}   🔄 Recrie o container com: docker stop open-webui && docker rm open-webui && ./start-server.sh${NC}"
                else
                    echo -e "${RED}   ❌ Nenhuma alternativa funcionou${NC}"
                fi
            fi
        fi
    fi
else
    echo -e "${RED}   ❌ Container open-webui não está rodando${NC}"
    if docker ps -a --format '{{.Names}}' | grep -q "^open-webui$"; then
        echo -e "${YELLOW}   Container existe mas está parado. Execute: docker start open-webui${NC}"
    else
        echo -e "${YELLOW}   Container não existe. Execute: ./start-server.sh${NC}"
    fi
fi

echo ""

# 3. Verificar rede Docker
echo -e "${YELLOW}3. Verificando rede Docker...${NC}"
DOCKER_GATEWAY=$(docker network inspect bridge --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' 2>/dev/null || echo "")
if [ -n "$DOCKER_GATEWAY" ]; then
    echo -e "${GREEN}   ✅ Gateway Docker: $DOCKER_GATEWAY${NC}"
    if curl -s --max-time 2 http://$DOCKER_GATEWAY:11434/api/tags >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Ollama acessível via gateway Docker${NC}"
    else
        echo -e "${RED}   ❌ Ollama NÃO acessível via gateway Docker${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Não foi possível determinar gateway Docker${NC}"
fi

echo ""

# 4. Verificar host.docker.internal
echo -e "${YELLOW}4. Verificando host.docker.internal...${NC}"
if docker run --rm --add-host=host.docker.internal:host-gateway alpine sh -c "ping -c 1 host.docker.internal >/dev/null 2>&1"; then
    echo -e "${GREEN}   ✅ host.docker.internal está disponível${NC}"
else
    echo -e "${YELLOW}   ⚠️  host.docker.internal pode não estar disponível (normal no WSL2)${NC}"
fi

echo ""
echo -e "${YELLOW}==========================================${NC}"
echo -e "${YELLOW}💡 Soluções recomendadas:${NC}"
echo -e "${YELLOW}==========================================${NC}"
echo ""
echo "1. Se o container não consegue acessar Ollama:"
echo "   docker stop open-webui"
echo "   docker rm open-webui"
echo "   ./start-server.sh"
echo ""
echo "2. Se Ollama não está acessível:"
echo "   sudo systemctl start ollama"
echo "   curl http://localhost:11434/api/tags"
echo ""
echo "3. Para ver logs do container:"
echo "   docker logs open-webui"
echo ""

