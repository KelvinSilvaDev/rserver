#!/bin/bash

# Script para diagnosticar e corrigir problemas com Docker

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Diagnosticando Docker...${NC}"
echo ""

# Verificar se Docker está instalado
if ! command -v docker &>/dev/null; then
    echo -e "${RED}❌ Docker não está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker encontrado: $(which docker)${NC}"

# Tentar executar docker --version
echo -e "${YELLOW}📋 Testando comando docker...${NC}"
if docker --version 2>&1 | grep -q "version"; then
    echo -e "${GREEN}✅ docker --version funcionou${NC}"
else
    echo -e "${RED}❌ docker --version falhou${NC}"
    docker --version 2>&1
fi

# Verificar se o daemon está rodando
echo -e "${YELLOW}📋 Verificando Docker daemon...${NC}"
if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker daemon está rodando${NC}"
else
    echo -e "${RED}❌ Docker daemon não está rodando ou inacessível${NC}"
    echo ""
    echo -e "${YELLOW}💡 Tentando soluções:${NC}"
    echo ""
    
    # Tentar reiniciar Docker (WSL2)
    echo -e "${YELLOW}1. Tentando reiniciar Docker no WSL2...${NC}"
    if command -v service &>/dev/null; then
        echo "   Executando: sudo service docker restart"
        echo "   (Você precisará executar isso manualmente)"
    fi
    
    echo ""
    echo -e "${YELLOW}2. Verificando se Docker Desktop está rodando no Windows...${NC}"
    echo "   Certifique-se de que o Docker Desktop está iniciado"
    
    echo ""
    echo -e "${YELLOW}3. Tentando reiniciar WSL2...${NC}"
    echo "   No PowerShell do Windows, execute:"
    echo "   wsl --shutdown"
    echo "   Depois reinicie o WSL"
fi

echo ""
echo -e "${YELLOW}📋 Testando docker ps...${NC}"
if docker ps >/dev/null 2>&1; then
    echo -e "${GREEN}✅ docker ps funcionou${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}" | head -5
else
    echo -e "${RED}❌ docker ps falhou${NC}"
    docker ps 2>&1 | head -5
fi

echo ""
echo -e "${YELLOW}💡 Se o Docker não estiver funcionando:${NC}"
echo "   1. Reinicie o Docker Desktop no Windows"
echo "   2. Ou reinicie o WSL2: wsl --shutdown (no PowerShell)"
echo "   3. Verifique se há atualizações pendentes do Docker"


