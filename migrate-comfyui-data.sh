#!/bin/bash

# Script para migrar dados do ComfyUI de uma instalação anterior
# Uso: ./migrate-comfyui-data.sh /caminho/para/comfyui/anterior

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📦 Migração de dados do ComfyUI${NC}"
echo ""

# Verificar se o caminho foi fornecido
if [ -z "$1" ]; then
    echo -e "${YELLOW}Uso: $0 /caminho/para/comfyui/anterior${NC}"
    echo ""
    echo "Exemplos de caminhos comuns:"
    echo "  - ~/ComfyUI"
    echo "  - /home/usuario/ComfyUI"
    echo "  - /mnt/c/Users/usuario/ComfyUI (Windows/WSL)"
    echo ""
    echo "Este script irá copiar:"
    echo "  - models/ (checkpoints, VAE, LoRA, etc.)"
    echo "  - output/ (imagens geradas)"
    echo "  - input/ (imagens de entrada)"
    echo "  - custom_nodes/ (extensões personalizadas)"
    exit 1
fi

OLD_COMFYUI_PATH="$1"

# Verificar se o caminho existe
if [ ! -d "$OLD_COMFYUI_PATH" ]; then
    echo -e "${RED}❌ Caminho não encontrado: $OLD_COMFYUI_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}📂 Caminho da instalação anterior: $OLD_COMFYUI_PATH${NC}"
echo ""

# Verificar se os volumes Docker existem
if ! docker volume inspect comfyui-models >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Volume comfyui-models não existe. Criando...${NC}"
    docker volume create comfyui-models
fi

if ! docker volume inspect comfyui-output >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Volume comfyui-output não existe. Criando...${NC}"
    docker volume create comfyui-output
fi

if ! docker volume inspect comfyui-input >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Volume comfyui-input não existe. Criando...${NC}"
    docker volume create comfyui-input
fi

# Verificar se container existe, se não, criar temporariamente
if ! docker ps -a --format '{{.Names}}' | grep -q "^comfyui$"; then
    echo -e "${YELLOW}⚠️  Container comfyui não existe. Criando temporariamente para migração...${NC}"
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^comfyui:local$"; then
        docker run -d --name comfyui-temp \
            -v comfyui-models:/app/ComfyUI/models \
            -v comfyui-output:/app/ComfyUI/output \
            -v comfyui-input:/app/ComfyUI/input \
            comfyui:local >/dev/null 2>&1
        sleep 3
        CONTAINER_NAME="comfyui-temp"
        TEMP_CONTAINER=true
    else
        echo -e "${RED}❌ Imagem comfyui:local não encontrada. Execute ./start-server.sh primeiro.${NC}"
        exit 1
    fi
else
    CONTAINER_NAME="comfyui"
    TEMP_CONTAINER=false
    # Garantir que está rodando
    if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
        docker start comfyui >/dev/null 2>&1
        sleep 3
    fi
fi

echo -e "${GREEN}✅ Container Docker encontrado: $CONTAINER_NAME${NC}"
echo "   Models:  /app/ComfyUI/models"
echo "   Output:  /app/ComfyUI/output"
echo "   Input:   /app/ComfyUI/input"
echo ""

# Função para copiar diretório usando docker cp (mais seguro, não precisa sudo)
copy_directory() {
    local source="$1"
    local container_path="$2"
    local name="$3"
    
    if [ -d "$source" ] && [ "$(ls -A $source 2>/dev/null)" ]; then
        echo -e "${YELLOW}📋 Copiando $name...${NC}"
        echo "   De: $source"
        echo "   Para: $container_path (no container)"
        
        # Verificar se container está rodando
        if ! docker ps --format '{{.Names}}' | grep -q "^comfyui$"; then
            echo -e "${YELLOW}   ⚠️  Container comfyui não está rodando. Iniciando temporariamente...${NC}"
            docker start comfyui >/dev/null 2>&1
            sleep 3
            TEMP_STARTED=true
        else
            TEMP_STARTED=false
        fi
        
        # Usar docker cp para copiar (não precisa de sudo)
        echo -e "${YELLOW}   📦 Copiando arquivos (isso pode levar alguns minutos)...${NC}"
        docker cp "$source/." "comfyui:$container_path/" 2>&1 | grep -E "error|Error|ERROR" || true
        
        if [ $? -eq 0 ] || docker exec comfyui test -d "$container_path" 2>/dev/null; then
            echo -e "${GREEN}   ✅ $name copiado com sucesso${NC}"
        else
            echo -e "${YELLOW}   ⚠️  Verifique se a cópia foi concluída${NC}"
        fi
        
        # Se iniciamos o container temporariamente, parar
        if [ "$TEMP_STARTED" = true ]; then
            docker stop comfyui >/dev/null 2>&1
        fi
        
        echo ""
    else
        echo -e "${YELLOW}   ⚠️  $name não encontrado ou vazio em $source${NC}"
        echo ""
    fi
}

# Copiar models
if [ -d "$OLD_COMFYUI_PATH/models" ]; then
    copy_directory "$OLD_COMFYUI_PATH/models" "/app/ComfyUI/models" "Models"
else
    echo -e "${YELLOW}⚠️  Diretório models não encontrado em $OLD_COMFYUI_PATH${NC}"
    echo ""
fi

# Copiar output
if [ -d "$OLD_COMFYUI_PATH/output" ]; then
    copy_directory "$OLD_COMFYUI_PATH/output" "/app/ComfyUI/output" "Output"
else
    echo -e "${YELLOW}⚠️  Diretório output não encontrado em $OLD_COMFYUI_PATH${NC}"
    echo ""
fi

# Copiar input
if [ -d "$OLD_COMFYUI_PATH/input" ]; then
    copy_directory "$OLD_COMFYUI_PATH/input" "/app/ComfyUI/input" "Input"
else
    echo -e "${YELLOW}⚠️  Diretório input não encontrado em $OLD_COMFYUI_PATH${NC}"
    echo ""
fi

# Copiar custom_nodes (se existir)
if [ -d "$OLD_COMFYUI_PATH/custom_nodes" ]; then
    echo -e "${YELLOW}📋 Copiando custom_nodes...${NC}"
    echo -e "${YELLOW}   ⚠️  Nota: custom_nodes precisam ser reinstalados dentro do container${NC}"
    echo -e "${YELLOW}   Os arquivos serão copiados, mas você pode precisar reinstalar dependências${NC}"
    
    copy_directory "$OLD_COMFYUI_PATH/custom_nodes" "/app/ComfyUI/custom_nodes" "Custom Nodes"
else
    echo -e "${YELLOW}⚠️  Diretório custom_nodes não encontrado em $OLD_COMFYUI_PATH${NC}"
    echo ""
fi

# Limpar container temporário se criado
if [ "$TEMP_CONTAINER" = true ]; then
    echo -e "${YELLOW}🧹 Removendo container temporário...${NC}"
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1
    echo ""
fi

echo -e "${GREEN}✅ Migração concluída!${NC}"
echo ""
echo -e "${YELLOW}📍 Localizações dos volumes Docker:${NC}"
MODELS_VOLUME=$(docker volume inspect comfyui-models --format '{{.Mountpoint}}' 2>/dev/null || echo "N/A")
OUTPUT_VOLUME=$(docker volume inspect comfyui-output --format '{{.Mountpoint}}' 2>/dev/null || echo "N/A")
INPUT_VOLUME=$(docker volume inspect comfyui-input --format '{{.Mountpoint}}' 2>/dev/null || echo "N/A")
echo "   Models:       $MODELS_VOLUME"
echo "   Output:       $OUTPUT_VOLUME"
echo "   Input:        $INPUT_VOLUME"
echo ""
echo -e "${GREEN}💡 Dica: Reinicie o container ComfyUI para ver os dados migrados:${NC}"
echo "   docker restart comfyui"

