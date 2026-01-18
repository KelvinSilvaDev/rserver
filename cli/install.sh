#!/bin/bash

# =============================================================================
# 📦 INSTALAÇÃO DO RSERVER - Remote Server Control
# Compatível com Linux e macOS
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       📦 INSTALAÇÃO DO RSERVER - Remote Server Control         ║"
echo "║              Linux / macOS / Unix-like Systems                 ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Detectar plataforma
OS_TYPE=$(uname -s)
echo -e "${YELLOW}🖥️  Sistema detectado: $OS_TYPE${NC}"

# Detectar diretório de instalação
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Verificar se é instalação do usuário (sem sudo)
USE_USER_INSTALL=false
if [[ "$INSTALL_DIR" == "$HOME"* ]] || [[ "$INSTALL_DIR" == *".local"* ]]; then
    USE_USER_INSTALL=true
    INSTALL_DIR="${HOME}/.local/bin"
    echo -e "${YELLOW}📂 Instalação do usuário: $INSTALL_DIR${NC}"
else
    echo -e "${YELLOW}📂 Instalação global: $INSTALL_DIR${NC}"
fi

echo -e "${YELLOW}📂 Diretório do projeto: $PROJECT_DIR${NC}"
echo ""

# Verificar Python 3
echo -e "${YELLOW}🐍 Verificando Python 3...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 não encontrado.${NC}"
    echo -e "${YELLOW}   Instale Python 3 primeiro:${NC}"
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        echo -e "${BLUE}   brew install python3${NC}"
        echo -e "${BLUE}   ou baixe de: https://www.python.org/downloads/${NC}"
    else
        echo -e "${BLUE}   sudo apt install python3  # Ubuntu/Debian${NC}"
        echo -e "${BLUE}   sudo yum install python3  # RHEL/CentOS${NC}"
    fi
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}✅ $PYTHON_VERSION encontrado${NC}"

# Verificar versão mínima (3.7+)
PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info.major)')
PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info.minor)')
if [[ $PYTHON_MAJOR -lt 3 ]] || [[ $PYTHON_MAJOR -eq 3 && $PYTHON_MINOR -lt 7 ]]; then
    echo -e "${RED}❌ Python 3.7+ é necessário. Versão atual: $PYTHON_VERSION${NC}"
    exit 1
fi

# Criar diretório de instalação se não existir
if [[ "$USE_USER_INSTALL" == true ]]; then
    mkdir -p "$INSTALL_DIR"
else
    if [[ ! -d "$INSTALL_DIR" ]]; then
        echo -e "${YELLOW}📁 Criando diretório $INSTALL_DIR...${NC}"
        sudo mkdir -p "$INSTALL_DIR"
    fi
fi

# Criar links simbólicos
echo -e "${YELLOW}🔗 Criando links simbólicos...${NC}"

CLI_NAME="rserver"
BACKUP_NAME="rsctl"  # Mantém para compatibilidade

# Verificar se rserver já existe
if [ -f "$INSTALL_DIR/$CLI_NAME" ]; then
    echo -e "${YELLOW}⚠️  $CLI_NAME já existe em $INSTALL_DIR${NC}"
    read -p "Deseja sobrescrever? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
        echo -e "${YELLOW}⏭️  Instalação cancelada${NC}"
        exit 0
    fi
    if [[ "$USE_USER_INSTALL" == true ]]; then
        rm "$INSTALL_DIR/$CLI_NAME"
    else
        sudo rm "$INSTALL_DIR/$CLI_NAME"
    fi
fi

# Criar wrapper script principal (rserver)
if [[ "$USE_USER_INSTALL" == true ]]; then
    tee "$INSTALL_DIR/$CLI_NAME" > /dev/null << EOF
#!/bin/bash
# Wrapper para rsctl_new.py (versão refatorada)
exec python3 "$PROJECT_DIR/cli/rsctl_new.py" "\$@"
EOF
    chmod +x "$INSTALL_DIR/$CLI_NAME"
else
    sudo tee "$INSTALL_DIR/$CLI_NAME" > /dev/null << EOF
#!/bin/bash
# Wrapper para rsctl_new.py (versão refatorada)
exec python3 "$PROJECT_DIR/cli/rsctl_new.py" "\$@"
EOF
    sudo chmod +x "$INSTALL_DIR/$CLI_NAME"
fi

echo -e "${GREEN}✅ Link simbólico criado: $INSTALL_DIR/$CLI_NAME${NC}"

# Criar também rsctl para compatibilidade (aponta para versão antiga)
if [ ! -f "$INSTALL_DIR/$BACKUP_NAME" ]; then
    if [[ "$USE_USER_INSTALL" == true ]]; then
        tee "$INSTALL_DIR/$BACKUP_NAME" > /dev/null << EOF
#!/bin/bash
# Wrapper para rsctl.py (versão legada - compatibilidade)
exec python3 "$PROJECT_DIR/cli/rsctl.py" "\$@"
EOF
        chmod +x "$INSTALL_DIR/$BACKUP_NAME"
    else
        sudo tee "$INSTALL_DIR/$BACKUP_NAME" > /dev/null << EOF
#!/bin/bash
# Wrapper para rsctl.py (versão legada - compatibilidade)
exec python3 "$PROJECT_DIR/cli/rsctl.py" "\$@"
EOF
        sudo chmod +x "$INSTALL_DIR/$BACKUP_NAME"
    fi
    echo -e "${GREEN}✅ Link de compatibilidade criado: $INSTALL_DIR/$BACKUP_NAME${NC}"
fi

# Verificar se está no PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}⚠️  $INSTALL_DIR não está no PATH${NC}"
    
    # Detectar shell
    SHELL_NAME=$(basename "$SHELL")
    if [[ "$SHELL_NAME" == "zsh" ]]; then
        CONFIG_FILE="$HOME/.zshrc"
    else
        CONFIG_FILE="$HOME/.bashrc"
    fi
    
    echo -e "${YELLOW}   Adicione ao seu $CONFIG_FILE:${NC}"
    echo -e "${BLUE}   export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
    echo ""
    read -p "Deseja adicionar automaticamente? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        if ! grep -q "$INSTALL_DIR" "$CONFIG_FILE" 2>/dev/null; then
            echo "" >> "$CONFIG_FILE"
            echo "# rserver CLI" >> "$CONFIG_FILE"
            echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$CONFIG_FILE"
            echo -e "${GREEN}✅ Adicionado ao $CONFIG_FILE${NC}"
            echo -e "${YELLOW}   Execute: source $CONFIG_FILE${NC}"
        else
            echo -e "${YELLOW}   Já está configurado em $CONFIG_FILE${NC}"
        fi
    fi
fi

# Verificar instalação
echo ""
echo -e "${YELLOW}🧪 Testando instalação...${NC}"
if command -v $CLI_NAME &> /dev/null || [ -f "$INSTALL_DIR/$CLI_NAME" ]; then
    echo -e "${GREEN}✅ $CLI_NAME instalado com sucesso!${NC}"
    echo ""
    echo -e "${BLUE}📖 Uso:${NC}"
    echo "   $CLI_NAME list              # Lista serviços disponíveis"
    echo "   $CLI_NAME status            # Mostra status de todos os serviços"
    echo "   $CLI_NAME start all         # Inicia todos os serviços"
    echo "   $CLI_NAME start ssh ollama   # Inicia serviços específicos"
    echo "   $CLI_NAME stop webui         # Para um serviço"
    echo ""
    if [[ "$USE_USER_INSTALL" == false ]]; then
        echo -e "${BLUE}📖 Uso (compatibilidade):${NC}"
        echo "   $BACKUP_NAME list           # Também funciona (versão antiga)"
        echo ""
    fi
    echo -e "${GREEN}✅ Instalação concluída!${NC}"
    echo -e "${YELLOW}💡 Dica: Use '$CLI_NAME' como comando principal${NC}"
    
    # Testar execução
    if command -v $CLI_NAME &> /dev/null; then
        echo ""
        echo -e "${YELLOW}🧪 Testando execução...${NC}"
        if $CLI_NAME --version &>/dev/null || $CLI_NAME --help &>/dev/null; then
            echo -e "${GREEN}✅ CLI está funcionando!${NC}"
        fi
    fi
else
    echo -e "${RED}❌ Erro: $CLI_NAME não encontrado após instalação${NC}"
    echo -e "${YELLOW}   Tente executar: $INSTALL_DIR/$CLI_NAME --help${NC}"
    exit 1
fi
