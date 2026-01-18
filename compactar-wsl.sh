#!/bin/bash

# Script para compactar o disco virtual do WSL2
# IMPORTANTE: Execute no PowerShell do Windows (como Administrador)

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}📦 Script para compactar disco virtual do WSL2${NC}"
echo ""
echo -e "${RED}⚠️  ATENÇÃO: Este script deve ser executado no PowerShell do Windows!${NC}"
echo ""
echo -e "${YELLOW}Passos:${NC}"
echo ""
echo -e "${BLUE}1. Feche o WSL2 completamente:${NC}"
echo -e "${GREEN}   wsl --shutdown${NC}"
echo ""
echo -e "${BLUE}2. Encontre o caminho do disco virtual:${NC}"
echo -e "${GREEN}   Get-ChildItem \"C:\\Users\\$USER\\AppData\\Local\\Packages\\*\\LocalState\\ext4.vhdx\"${NC}"
echo ""
echo -e "${BLUE}3. Compacte o disco:${NC}"
echo -e "${GREEN}   Optimize-VHD -Path \"CAMINHO_DO_VHDX\" -Mode Full${NC}"
echo ""
echo -e "${YELLOW}Ou execute este comando completo (ajuste o caminho se necessário):${NC}"
echo ""
echo -e "${GREEN}wsl --shutdown${NC}"
echo -e "${GREEN}\$vhdx = Get-ChildItem \"C:\\Users\\$env:USERNAME\\AppData\\Local\\Packages\\*\\LocalState\\ext4.vhdx\" | Select-Object -First 1${NC}"
echo -e "${GREEN}Optimize-VHD -Path \$vhdx.FullName -Mode Full${NC}"
echo ""
echo -e "${YELLOW}💡 Dica: Isso pode levar vários minutos dependendo do tamanho${NC}"


