#!/bin/bash

# Testar todas as URLs do Ollama a partir do container

echo "🔍 Testando URLs do Ollama a partir do container open-webui..."
echo ""

URLS=(
    "http://host.docker.internal:11434"
    "http://172.17.0.1:11434"
    "http://100.75.221.92:11434"
    "https://drive-move-incentives-restaurant.trycloudflare.com"
)

for URL in "${URLS[@]}"; do
    echo -n "Testando $URL ... "
    RESULT=$(docker exec open-webui sh -c "curl -s --max-time 5 $URL/api/tags 2>&1" | head -c 100)
    if echo "$RESULT" | grep -q "models"; then
        echo "✅ FUNCIONA!"
        echo "   Resposta: $(echo "$RESULT" | head -c 150)"
    else
        echo "❌ NÃO FUNCIONA"
        if [ -n "$RESULT" ]; then
            echo "   Erro: $RESULT"
        fi
    fi
    echo ""
done

echo ""
echo "📋 Testando do host (para comparação):"
echo -n "http://localhost:11434 ... "
if curl -s --max-time 2 http://localhost:11434/api/tags | grep -q "models"; then
    echo "✅ FUNCIONA"
else
    echo "❌ NÃO FUNCIONA"
fi

echo -n "http://172.17.0.1:11434 ... "
if curl -s --max-time 2 http://172.17.0.1:11434/api/tags | grep -q "models"; then
    echo "✅ FUNCIONA"
else
    echo "❌ NÃO FUNCIONA"
fi

