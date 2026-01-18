#!/bin/bash

# =============================================================================
# 🚀 INICIAR SERVIDOR REMOTO
# =============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$(dirname "$0")"
mkdir -p logs

# Inicializar variáveis
TAILSCALE_WEBUI_URL=""
TAILSCALE_COMFYUI_URL=""
TAILSCALE_IP=""
TAILSCALE_DOMAIN=""

echo -e "${YELLOW}🚀 Iniciando servidor remoto...${NC}"
echo ""

# 1. SSH
echo -e "${YELLOW}🔐 Iniciando SSH...${NC}"
sudo service ssh start
echo -e "${GREEN}✅ SSH rodando na porta 22${NC}"

# 2. Tailscale (verificar se conectado)
echo ""
echo -e "${YELLOW}🌐 Verificando Tailscale...${NC}"
if tailscale status &>/dev/null; then
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null)
    echo -e "${GREEN}✅ Tailscale conectado: $TAILSCALE_IP${NC}"
    
    # Configurar Tailscale Serve para Web-UI (porta 3000)
    echo -e "${YELLOW}🌐 Configurando Tailscale Serve para Web-UI...${NC}"
    SERVE_OUTPUT=$(sudo tailscale serve --bg --http 80 http://127.0.0.1:3000 2>&1)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Tailscale Serve configurado para Web-UI${NC}"
        # Extrair URL do output se disponível
        TAILSCALE_WEBUI_URL_TEMP=$(echo "$SERVE_OUTPUT" | grep -o 'http://[^[:space:]]*\.ts\.net' | head -1)
        if [ -n "$TAILSCALE_WEBUI_URL_TEMP" ]; then
            TAILSCALE_WEBUI_URL="$TAILSCALE_WEBUI_URL_TEMP"
        fi
    else
        # Pode já estar configurado, verificar
        if echo "$SERVE_OUTPUT" | grep -q "already"; then
            echo -e "${GREEN}✅ Tailscale Serve já configurado para Web-UI${NC}"
        else
            echo -e "${YELLOW}⚠️  Não foi possível configurar Tailscale Serve para Web-UI${NC}"
        fi
    fi
    
    # Configurar Tailscale Serve para ComfyUI (porta 8188)
    echo -e "${YELLOW}🎨 Configurando Tailscale Serve para ComfyUI...${NC}"
    SERVE_COMFY_OUTPUT=$(sudo tailscale serve --bg --http 8188 http://127.0.0.1:8188 2>&1)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Tailscale Serve configurado para ComfyUI${NC}"
        # Extrair URL do output se disponível
        TAILSCALE_COMFYUI_URL_TEMP=$(echo "$SERVE_COMFY_OUTPUT" | grep -o 'http://[^[:space:]]*\.ts\.net' | head -1)
        if [ -n "$TAILSCALE_COMFYUI_URL_TEMP" ]; then
            TAILSCALE_COMFYUI_URL="$TAILSCALE_COMFYUI_URL_TEMP"
        fi
    else
        # Pode já estar configurado, verificar
        if echo "$SERVE_COMFY_OUTPUT" | grep -q "already"; then
            echo -e "${GREEN}✅ Tailscale Serve já configurado para ComfyUI${NC}"
        else
            echo -e "${YELLOW}⚠️  Não foi possível configurar Tailscale Serve para ComfyUI${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  Tailscale não conectado. Execute: sudo tailscale up${NC}"
    # Tentar obter IP mesmo assim (pode estar conectado mas não respondendo ao status)
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "")
fi

# 3. Ollama
echo -e "${YELLOW}🤖 Iniciando Ollama (systemd)...${NC}"
sudo systemctl start ollama
sleep 2

# Verificar se Ollama está acessível
if curl -s --max-time 2 http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Ollama rodando e acessível${NC}"
else
    echo -e "${YELLOW}⚠️  Ollama pode não estar acessível. Verificando...${NC}"
    sleep 1
    if curl -s --max-time 2 http://localhost:11434/api/tags >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Ollama agora está acessível${NC}"
    else
        echo -e "${YELLOW}⚠️  Ollama pode precisar de configuração adicional${NC}"
    fi
fi

echo -e "${GREEN}✅ Ollama rodando em:${NC}"
echo "   - WSL:      http://localhost:11434"
echo "   - Windows:  http://172.20.225.38:11434"
if [ -n "$TAILSCALE_IP" ]; then
    echo "   - Tailscale:http://$TAILSCALE_IP:11434"
fi

# 3.5. Web-UI (Open WebUI)
echo ""
echo -e "${YELLOW}🌐 Verificando Web-UI (Open WebUI)...${NC}"

# Determinar URL do Ollama para o container Docker
# IMPORTANTE: Container Docker não tem acesso direto à rede Tailscale
# Deve usar IP do WSL (172.20.225.38) ou gateway Docker, NÃO o IP do Tailscale
WSL_HOST_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "")
if [ -n "$WSL_HOST_IP" ]; then
    OLLAMA_URL="http://$WSL_HOST_IP:11434"
    echo -e "${YELLOW}   Usando IP do WSL para container: $OLLAMA_URL${NC}"
else
    # Fallback: gateway do Docker
    DOCKER_GATEWAY_IP=$(docker network inspect bridge --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' 2>/dev/null || echo "172.17.0.1")
    OLLAMA_URL="http://$DOCKER_GATEWAY_IP:11434"
    echo -e "${YELLOW}   Usando gateway Docker: $OLLAMA_URL${NC}"
fi

if docker ps --format '{{.Names}}' | grep -q "^open-webui$"; then
    echo -e "${GREEN}✅ Web-UI já está rodando${NC}"
    CURRENT_OLLAMA_URL=$(docker inspect open-webui --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | grep "^OLLAMA_BASE_URL=" | cut -d'=' -f2- || echo "")
    echo -e "${YELLOW}   OLLAMA_BASE_URL atual: ${CURRENT_OLLAMA_URL:-não configurado}${NC}"
    echo -e "${YELLOW}   OLLAMA_BASE_URL esperado: $OLLAMA_URL${NC}"
    
    # Verificar se precisa atualizar (IP mudou)
    if [ -n "$CURRENT_OLLAMA_URL" ] && [ "$CURRENT_OLLAMA_URL" != "$OLLAMA_URL" ]; then
        echo -e "${YELLOW}   🔄 IP mudou! Recriando container com nova configuração...${NC}"
        docker stop open-webui >/dev/null 2>&1
        docker rm open-webui >/dev/null 2>&1
        if docker run -d \
            --name open-webui \
            -p 3000:8080 \
            --restart always \
            --add-host=host.docker.internal:host-gateway \
            -e OLLAMA_BASE_URL="$OLLAMA_URL" \
            -v open-webui:/app/backend/data \
            ghcr.io/open-webui/open-webui:latest 2>/dev/null; then
            sleep 3
            echo -e "${GREEN}   ✅ Container recriado com OLLAMA_BASE_URL=$OLLAMA_URL${NC}"
        else
            echo -e "${YELLOW}   ⚠️  Erro ao recriar container${NC}"
        fi
    fi
    
    # Verificar conectividade do container com o Ollama
    echo -e "${YELLOW}   Testando conectividade com Ollama em $OLLAMA_URL...${NC}"
    if docker exec open-webui sh -c "curl -s --max-time 5 $OLLAMA_URL/api/tags" >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Container consegue acessar Ollama${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Container não consegue acessar Ollama em $OLLAMA_URL${NC}"
        echo -e "${YELLOW}   Verifique se Ollama está rodando e acessível${NC}"
    fi
elif docker ps -a --format '{{.Names}}' | grep -q "^open-webui$"; then
    # Container existe mas está parado, iniciar
    echo -e "${YELLOW}🔄 Container open-webui existe mas está parado. Reiniciando...${NC}"
    docker start open-webui >/dev/null 2>&1
    sleep 2
    if docker ps --format '{{.Names}}' | grep -q "^open-webui$"; then
        echo -e "${GREEN}✅ Web-UI reiniciado${NC}"
    else
        echo -e "${YELLOW}⚠️  Erro ao reiniciar container. Recriando...${NC}"
        docker rm -f open-webui >/dev/null 2>&1
        if docker run -d \
            --name open-webui \
            -p 3000:8080 \
            --restart always \
            --add-host=host.docker.internal:host-gateway \
            -e OLLAMA_BASE_URL="$OLLAMA_URL" \
            -v open-webui:/app/backend/data \
            ghcr.io/open-webui/open-webui:latest 2>/dev/null; then
            sleep 3
            echo -e "${GREEN}✅ Web-UI recriado e iniciado com OLLAMA_BASE_URL=$OLLAMA_URL${NC}"
        else
            echo -e "${YELLOW}⚠️  Erro ao recriar container open-webui${NC}"
        fi
    fi
else
    # Container não existe, criar e iniciar
    echo -e "${YELLOW}🚀 Criando e iniciando container open-webui...${NC}"
        if docker run -d \
            --name open-webui \
            -p 3000:8080 \
            --restart always \
            --add-host=host.docker.internal:host-gateway \
            -e OLLAMA_BASE_URL="$OLLAMA_URL" \
            -v open-webui:/app/backend/data \
            ghcr.io/open-webui/open-webui:latest 2>/dev/null; then
            sleep 3
            echo -e "${GREEN}✅ Web-UI criado e iniciado com OLLAMA_BASE_URL=$OLLAMA_URL${NC}"
        
        # Testar conectividade após iniciar
        echo -e "${YELLOW}   Testando conectividade com Ollama...${NC}"
        sleep 2
        if docker exec open-webui sh -c "curl -s --max-time 5 $OLLAMA_URL/api/tags" >/dev/null 2>&1; then
            echo -e "${GREEN}   ✅ Container consegue acessar Ollama${NC}"
        else
            echo -e "${YELLOW}   ⚠️  Container não consegue acessar Ollama. Verifique se Ollama está rodando.${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Erro ao criar container open-webui${NC}"
    fi
fi

# 3.6. ComfyUI
echo ""
echo -e "${YELLOW}🎨 Verificando ComfyUI...${NC}"

# Verificar se está rodando como container Docker
if docker ps --format '{{.Names}}' | grep -qi "comfyui"; then
    echo -e "${GREEN}✅ ComfyUI (Docker) já está rodando${NC}"
    # Verificar se está acessível
    if curl -s --max-time 2 http://127.0.0.1:8188 >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ ComfyUI acessível em localhost:8188${NC}"
    else
        echo -e "${YELLOW}   ⚠️  ComfyUI não está acessível em localhost:8188${NC}"
    fi
# Verificar se está rodando como processo e acessível em localhost
elif curl -s --max-time 2 http://127.0.0.1:8188 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ ComfyUI já está rodando e acessível em localhost:8188${NC}"
elif ss -lntp 2>/dev/null | grep -q "127.0.0.1:8188"; then
    echo -e "${GREEN}✅ ComfyUI está escutando em localhost:8188${NC}"
elif ss -lntp 2>/dev/null | grep -q ":8188"; then
    # Algo está na porta 8188, mas não em localhost - pode ser o Tailscale Serve
    # Verificar se ComfyUI está realmente rodando
    if ! curl -s --max-time 2 http://127.0.0.1:8188 >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Algo está na porta 8188, mas ComfyUI não está acessível em localhost${NC}"
        echo -e "${YELLOW}🚀 Iniciando ComfyUI via Docker...${NC}"
        
        if command -v docker &>/dev/null; then
            # Verificar se container existe mas está parado
            if docker ps -a --format '{{.Names}}' | grep -qi "comfyui"; then
                echo -e "${YELLOW}   Container existe mas está parado. Reiniciando...${NC}"
                docker start comfyui >/dev/null 2>&1
                sleep 3
                if curl -s --max-time 2 http://127.0.0.1:8188 >/dev/null 2>&1; then
                    echo -e "${GREEN}✅ ComfyUI reiniciado e acessível${NC}"
                else
                    echo -e "${YELLOW}   ⚠️  Container reiniciado mas não está acessível ainda${NC}"
                fi
        else
            # Criar novo container
            echo -e "${YELLOW}   Criando container ComfyUI...${NC}"
            # Usar imagem local do ComfyUI (sem autenticação)
            # Se não existir, construir primeiro (pode levar 5-10 minutos)
            if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^comfyui:local$"; then
                echo -e "${YELLOW}   Construindo imagem local do ComfyUI (pode levar 5-10 minutos)...${NC}"
                echo -e "${YELLOW}   Isso é feito apenas uma vez. Aguarde...${NC}"
                SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
                cd "$SCRIPT_DIR/docker/comfyui" && \
                docker build -t comfyui:local . && \
                cd - >/dev/null
                if [ $? -ne 0 ]; then
                    echo -e "${YELLOW}   ⚠️  Erro ao construir imagem. Tente manualmente: cd docker/comfyui && ./build.sh${NC}"
                    # Continuar mesmo se falhar - a imagem pode já existir
                fi
            fi
            
            # Usar bind mounts para acessar diretamente do Windows
            # Caminho da instalação anterior do ComfyUI no Windows
            WINDOWS_COMFYUI_PATH="/mnt/c/Users/klvml/Downloads/ComfyUI-Easy-Install/ComfyUI-Easy-Install/ComfyUI"
            
            # Verificar se o caminho existe, se não, usar volumes Docker
            if [ -d "$WINDOWS_COMFYUI_PATH" ]; then
                echo -e "${YELLOW}   Usando bind mounts (acesso direto do Windows)${NC}"
                MOUNT_MODELS="-v $WINDOWS_COMFYUI_PATH/models:/app/ComfyUI/models"
                MOUNT_OUTPUT="-v $WINDOWS_COMFYUI_PATH/output:/app/ComfyUI/output"
                MOUNT_INPUT="-v $WINDOWS_COMFYUI_PATH/input:/app/ComfyUI/input"
                MOUNT_CUSTOM="-v $WINDOWS_COMFYUI_PATH/custom_nodes:/app/ComfyUI/custom_nodes"
            else
                echo -e "${YELLOW}   Caminho do Windows não encontrado, usando volumes Docker${NC}"
                MOUNT_MODELS="-v comfyui-models:/app/ComfyUI/models"
                MOUNT_OUTPUT="-v comfyui-output:/app/ComfyUI/output"
                MOUNT_INPUT="-v comfyui-input:/app/ComfyUI/input"
                MOUNT_CUSTOM=""
            fi
            
            if docker run -d \
                --name comfyui \
                -p 127.0.0.1:8188:8188 \
                --restart always \
                --gpus all \
                $MOUNT_MODELS \
                $MOUNT_OUTPUT \
                $MOUNT_INPUT \
                $MOUNT_CUSTOM \
                comfyui:local 2>/dev/null; then
                    sleep 5
                    if curl -s --max-time 5 http://127.0.0.1:8188 >/dev/null 2>&1; then
                        echo -e "${GREEN}✅ ComfyUI criado e iniciado${NC}"
                    else
                        echo -e "${YELLOW}   ⚠️  Container criado, aguardando inicialização...${NC}"
                        echo -e "${YELLOW}   Pode levar alguns minutos na primeira execução${NC}"
                    fi
                else
                    echo -e "${YELLOW}⚠️  Erro ao criar container ComfyUI${NC}"
                    echo -e "${YELLOW}   A imagem ai-dock/comfyui requer GPU NVIDIA com drivers instalados.${NC}"
                    echo -e "${YELLOW}   Verifique se você tem GPU NVIDIA e drivers instalados.${NC}"
                    echo -e "${YELLOW}   Você pode iniciar manualmente com:${NC}"
                    echo -e "${YELLOW}   docker run -d --name comfyui -p 127.0.0.1:8188:8188 --restart always --gpus all comfyui:local${NC}"
                    echo -e "${YELLOW}   Ou construa a imagem primeiro: cd docker/comfyui && ./build.sh${NC}"
                fi
            fi
        else
            echo -e "${YELLOW}⚠️  Docker não encontrado. Instale Docker para usar ComfyUI.${NC}"
        fi
    fi
else
    # ComfyUI não está rodando, iniciar via Docker
    echo -e "${YELLOW}🚀 ComfyUI não encontrado. Iniciando via Docker...${NC}"
    
    if command -v docker &>/dev/null; then
        # Verificar se container existe mas está parado
        if docker ps -a --format '{{.Names}}' | grep -qi "comfyui"; then
            echo -e "${YELLOW}   Container existe mas está parado. Reiniciando...${NC}"
            docker start comfyui >/dev/null 2>&1
            sleep 3
            if curl -s --max-time 2 http://127.0.0.1:8188 >/dev/null 2>&1; then
                echo -e "${GREEN}✅ ComfyUI reiniciado e acessível${NC}"
            else
                echo -e "${YELLOW}   ⚠️  Container reiniciado mas não está acessível ainda${NC}"
            fi
        else
            # Criar novo container
            echo -e "${YELLOW}   Criando container ComfyUI...${NC}"
            # Usar imagem local do ComfyUI (sem autenticação)
            # Se não existir, construir primeiro
            if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^comfyui:local$"; then
                echo -e "${YELLOW}   Construindo imagem local do ComfyUI (pode levar alguns minutos)...${NC}"
                cd "$(dirname "$0")/docker/comfyui" && \
                docker build -t comfyui:local . >/dev/null 2>&1 && \
                cd - >/dev/null
            fi
            
            # Usar bind mounts para acessar diretamente do Windows
            # Caminho da instalação anterior do ComfyUI no Windows
            WINDOWS_COMFYUI_PATH="/mnt/c/Users/klvml/Downloads/ComfyUI-Easy-Install/ComfyUI-Easy-Install/ComfyUI"
            
            # Verificar se o caminho existe, se não, usar volumes Docker
            if [ -d "$WINDOWS_COMFYUI_PATH" ]; then
                echo -e "${YELLOW}   Usando bind mounts (acesso direto do Windows)${NC}"
                MOUNT_MODELS="-v $WINDOWS_COMFYUI_PATH/models:/app/ComfyUI/models"
                MOUNT_OUTPUT="-v $WINDOWS_COMFYUI_PATH/output:/app/ComfyUI/output"
                MOUNT_INPUT="-v $WINDOWS_COMFYUI_PATH/input:/app/ComfyUI/input"
                MOUNT_CUSTOM="-v $WINDOWS_COMFYUI_PATH/custom_nodes:/app/ComfyUI/custom_nodes"
            else
                echo -e "${YELLOW}   Caminho do Windows não encontrado, usando volumes Docker${NC}"
                MOUNT_MODELS="-v comfyui-models:/app/ComfyUI/models"
                MOUNT_OUTPUT="-v comfyui-output:/app/ComfyUI/output"
                MOUNT_INPUT="-v comfyui-input:/app/ComfyUI/input"
                MOUNT_CUSTOM=""
            fi
            
            if docker run -d \
                --name comfyui \
                -p 127.0.0.1:8188:8188 \
                --restart always \
                --gpus all \
                $MOUNT_MODELS \
                $MOUNT_OUTPUT \
                $MOUNT_INPUT \
                $MOUNT_CUSTOM \
                comfyui:local 2>/dev/null; then
                sleep 5
                if curl -s --max-time 5 http://127.0.0.1:8188 >/dev/null 2>&1; then
                    echo -e "${GREEN}✅ ComfyUI criado e iniciado${NC}"
                else
                    echo -e "${YELLOW}   ⚠️  Container criado, aguardando inicialização...${NC}"
                    echo -e "${YELLOW}   Pode levar alguns minutos na primeira execução${NC}"
                fi
            else
                echo -e "${YELLOW}⚠️  Erro ao criar container ComfyUI${NC}"
                echo -e "${YELLOW}   A imagem ai-dock/comfyui requer GPU NVIDIA com drivers instalados.${NC}"
                echo -e "${YELLOW}   Verifique se você tem GPU NVIDIA e drivers instalados.${NC}"
                echo -e "${YELLOW}   Você pode iniciar manualmente com:${NC}"
                echo -e "${YELLOW}   docker run -d --name comfyui -p 8188:8188 --restart always ghcr.io/ai-dock/comfyui:latest${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  Docker não encontrado. Instale Docker para usar ComfyUI.${NC}"
    fi
fi

# echo ""
# echo -e "${YELLOW}🤖 Iniciando Ollama...${NC}"
# if ! pgrep -x "ollama" > /dev/null; then
#     nohup ollama serve > logs/ollama.log 2>&1 &
#     sleep 3
# fi
# echo -e "${GREEN}✅ Ollama rodando em http://localhost:11434${NC}"

# 4. Cloudflare Tunnels
echo ""
echo -e "${YELLOW}☁️ Iniciando Cloudflare Tunnels...${NC}"

# Matar tunnels antigos
pkill -f "cloudflared tunnel" 2>/dev/null || true
sleep 2

# Criar diretório de logs se não existir
mkdir -p logs

# SSH Tunnel
nohup cloudflared tunnel --url ssh://localhost:22 > logs/tunnel-ssh.log 2>&1 &
sleep 5

# Ollama Tunnel (API)
nohup cloudflared tunnel --url http://localhost:11434 > logs/tunnel-ollama.log 2>&1 &
sleep 5

echo -e "${GREEN}✅ Tunnels criados${NC}"

# Mostrar URLs
echo ""
echo "=========================================="
echo "         📍 URLS DE ACESSO               "
echo "=========================================="
echo ""

SSH_URL=$(grep -o 'https://.*trycloudflare.com' logs/tunnel-ssh.log 2>/dev/null | head -1)
OLLAMA_URL=$(grep -o 'https://.*trycloudflare.com' logs/tunnel-ollama.log 2>/dev/null | head -1)
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "Não conectado")

# Obter URLs do Tailscale Serve (se não foram capturadas anteriormente)
if tailscale status &>/dev/null; then
    # Se TAILSCALE_DOMAIN não foi definido anteriormente, definir agora
    if [ -z "$TAILSCALE_DOMAIN" ]; then
        HOSTNAME=$(hostname | tr '[:upper:]' '[:lower:]' 2>/dev/null || echo "")
        TAILSCALE_DOMAIN=$(tailscale status --json 2>/dev/null | grep -o '"DNSName":"[^"]*\.ts\.net"' | head -1 | cut -d'"' -f4 || echo "")
        if [ -z "$TAILSCALE_DOMAIN" ] && [ -n "$HOSTNAME" ]; then
            # Fallback: usar padrão comum do Tailscale
            TAILSCALE_DOMAIN="${HOSTNAME}.tail57ffa8.ts.net"
        fi
    fi
    
    # Web-UI (porta 80)
    if [ -z "$TAILSCALE_WEBUI_URL" ] && [ -n "$TAILSCALE_DOMAIN" ]; then
        TAILSCALE_WEBUI_URL="http://${TAILSCALE_DOMAIN}"
    fi
    
    # ComfyUI (porta 8188)
    if [ -z "$TAILSCALE_COMFYUI_URL" ] && [ -n "$TAILSCALE_DOMAIN" ]; then
        TAILSCALE_COMFYUI_URL="http://${TAILSCALE_DOMAIN}:8188"
    fi
fi

echo "🔐 SSH via Cloudflare: $SSH_URL"
echo "🤖 Ollama API:         $OLLAMA_URL"
if [ -n "$TAILSCALE_WEBUI_URL" ]; then
    echo "🌐 Web-UI (Tailscale):  $TAILSCALE_WEBUI_URL"
fi
if [ -n "$TAILSCALE_COMFYUI_URL" ]; then
    echo "🎨 ComfyUI (Tailscale): $TAILSCALE_COMFYUI_URL"
fi
echo "🌐 Tailscale IP:       $TAILSCALE_IP"
echo ""
echo "=========================================="
echo ""
echo -e "${YELLOW}Para conectar via SSH (Tailscale):${NC}"
echo "    ssh kelvin@$TAILSCALE_IP"
echo ""
echo -e "${YELLOW}Para conectar via SSH (Cloudflare):${NC}"
echo "    cloudflared access ssh --hostname $SSH_URL"

