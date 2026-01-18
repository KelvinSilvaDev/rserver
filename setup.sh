#!/bin/bash

# =============================================================================
# 🖥️ SETUP COMPLETO - SERVIDOR REMOTO WSL
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       🖥️  SETUP DO SERVIDOR REMOTO WSL                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# -----------------------------------------------------------------------------
# 1. ATUALIZAR SISTEMA
# -----------------------------------------------------------------------------
echo -e "${YELLOW}📦 Atualizando sistema...${NC}"
sudo apt update && sudo apt upgrade -y

# -----------------------------------------------------------------------------
# 2. INSTALAR SSH SERVER
# -----------------------------------------------------------------------------
echo -e "${YELLOW}🔐 Configurando SSH...${NC}"
sudo apt install -y openssh-server

# Configurar SSH
sudo tee /etc/ssh/sshd_config.d/remote-server.conf > /dev/null << 'EOF'
Port 22
PasswordAuthentication yes
PubkeyAuthentication yes
PermitRootLogin no
X11Forwarding yes
AllowTcpForwarding yes
GatewayPorts yes
EOF

# Iniciar SSH
sudo service ssh start
echo -e "${GREEN}✅ SSH configurado na porta 22${NC}"

# -----------------------------------------------------------------------------
# 3. INSTALAR TAILSCALE
# -----------------------------------------------------------------------------
echo -e "${YELLOW}🌐 Instalando Tailscale...${NC}"
curl -fsSL https://tailscale.com/install.sh | sh
echo -e "${GREEN}✅ Tailscale instalado${NC}"

# -----------------------------------------------------------------------------
# 4. INSTALAR OLLAMA (para modelos de IA)
# -----------------------------------------------------------------------------
echo -e "${YELLOW}🤖 Instalando Ollama...${NC}"
curl -fsSL https://ollama.com/install.sh | sh
echo -e "${GREEN}✅ Ollama instalado${NC}"

# -----------------------------------------------------------------------------
# 5. INSTALAR CLOUDFLARED
# -----------------------------------------------------------------------------
echo -e "${YELLOW}☁️ Instalando Cloudflared...${NC}"
if [ ! -f /usr/local/bin/cloudflared ]; then
    curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared
    sudo mv /tmp/cloudflared /usr/local/bin/cloudflared
    sudo chmod +x /usr/local/bin/cloudflared
fi
echo -e "${GREEN}✅ Cloudflared instalado${NC}"

# -----------------------------------------------------------------------------
# 6. CONFIGURAR SCRIPTS DE INICIALIZAÇÃO
# -----------------------------------------------------------------------------
echo -e "${YELLOW}⚙️ Configurando scripts...${NC}"

# Criar diretório de logs
mkdir -p ~/remote-server/logs

# Script de status
cat > ~/remote-server/status.sh << 'EOF'
#!/bin/bash
echo "=== STATUS DO SERVIDOR ==="
echo ""
echo "🔐 SSH:"
service ssh status 2>/dev/null | head -3 || echo "  Não está rodando"
echo ""
echo "🌐 Tailscale:"
tailscale status 2>/dev/null || echo "  Não conectado"
echo ""
echo "🤖 Ollama:"
curl -s http://localhost:11434/api/tags 2>/dev/null && echo "  Rodando" || echo "  Não está rodando"
echo ""
echo "☁️ Tunnels Cloudflare:"
pgrep -a cloudflared 2>/dev/null || echo "  Nenhum tunnel ativo"
EOF
chmod +x ~/remote-server/status.sh

echo -e "${GREEN}✅ Scripts configurados${NC}"

# -----------------------------------------------------------------------------
# RESUMO
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    ✅ SETUP COMPLETO!                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${YELLOW}PRÓXIMOS PASSOS:${NC}"
echo ""
echo "1️⃣  Conectar Tailscale:"
echo "    ${GREEN}sudo tailscale up${NC}"
echo ""
echo "2️⃣  Baixar um modelo Ollama:"
echo "    ${GREEN}ollama pull llama3.2${NC}"
echo ""
echo "3️⃣  Iniciar servidor:"
echo "    ${GREEN}./start-server.sh${NC}"
echo ""
echo "4️⃣  Ver status:"
echo "    ${GREEN}./status.sh${NC}"

