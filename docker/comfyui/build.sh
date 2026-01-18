#!/bin/bash
# Script para construir a imagem Docker do ComfyUI

cd "$(dirname "$0")"

echo "🔨 Construindo imagem Docker do ComfyUI..."
docker build -t comfyui:local .

if [ $? -eq 0 ]; then
    echo "✅ Imagem construída com sucesso!"
    echo "Para usar: docker run -d --name comfyui -p 8188:8188 --gpus all comfyui:local"
else
    echo "❌ Erro ao construir imagem"
    exit 1
fi

