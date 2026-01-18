#!/bin/bash

# Script para limpar espaço do Docker de forma segura

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}🧹 Limpando espaço do Docker...${NC}"
echo ""

# Mostrar uso atual
echo -e "${BLUE}📊 Uso atual do Docker:${NC}"
docker system df
echo ""

# Limpar containers parados
echo -e "${YELLOW}1. Removendo containers parados...${NC}"
STOPPED=$(docker ps -a -q -f status=exited 2>/dev/null | wc -l)
if [ "$STOPPED" -gt 0 ]; then
    docker container prune -f
    echo -e "${GREEN}✅ Containers parados removidos${NC}"
else
    echo -e "${GREEN}✅ Nenhum container parado${NC}"
fi
echo ""

# Limpar imagens não utilizadas (mas manter as que estão em uso)
echo -e "${YELLOW}2. Removendo imagens não utilizadas...${NC}"
docker image prune -f
echo -e "${GREEN}✅ Imagens não utilizadas removidas${NC}"
echo ""

# Limpar volumes não utilizados (CUIDADO: só os que não estão em uso)
echo -e "${YELLOW}3. Removendo volumes não utilizados...${NC}"
echo -e "${YELLOW}   ⚠️  Isso só remove volumes que NÃO estão sendo usados por containers${NC}"
docker volume prune -f
echo -e "${GREEN}✅ Volumes não utilizados removidos${NC}"
echo ""

# Limpar cache de build
echo -e "${YELLOW}4. Limpando cache de build...${NC}"
docker builder prune -f
echo -e "${GREEN}✅ Cache de build limpo${NC}"
echo ""

# Mostrar uso após limpeza
echo ""
echo -e "${BLUE}📊 Uso após limpeza:${NC}"
docker system df

echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo -e "${YELLOW}   O WSL2 pode não liberar o espaço imediatamente.${NC}"
echo -e "${YELLOW}   Para liberar o espaço no Windows, você precisa:${NC}"
echo ""
echo -e "${BLUE}   1. Fechar o WSL2${NC}"
echo -e "${BLUE}   2. No PowerShell (como Admin):${NC}"
echo -e "${GREEN}      wsl --shutdown${NC}"
echo -e "${BLUE}   3. Compactar o disco virtual:${NC}"
echo -e "${GREEN}      Optimize-VHD -Path \"C:\\Users\\klvml\\AppData\\Local\\Packages\\CanonicalGroupLimited.Ubuntu*\LocalState\\ext4.vhdx\" -Mode Full${NC}"
echo ""
echo -e "${YELLOW}   Ou use o script: ./compactar-wsl.sh${NC}"


