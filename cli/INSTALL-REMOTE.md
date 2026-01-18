# 🌐 Instalação Remota do RSERVER

Guia para instalar o RSERVER em um servidor Linux remoto.

## 📋 Pré-requisitos

- Servidor Linux (Ubuntu/Debian recomendado)
- Acesso SSH ao servidor
- Python 3 instalado
- Permissões sudo (para alguns serviços)

## 🚀 Métodos de Instalação

### Método 1: Via Git Clone (Recomendado)

Se o projeto está em um repositório Git:

```bash
# Conectar ao servidor
ssh user@servidor

# Clonar repositório
git clone <seu-repositorio> /opt/remote-server
cd /opt/remote-server

# Instalar CLI
sudo ./cli/install.sh

# Testar
rserver --help
```

### Método 2: Via SCP (Transferência Manual)

Do seu computador local:

```bash
# Transferir arquivos
scp -r cli/ user@servidor:/opt/remote-server/

# Conectar e instalar
ssh user@servidor
cd /opt/remote-server
sudo ./cli/install.sh
```

### Método 3: Script de Instalação Automática

Crie um script de instalação remota:

```bash
#!/bin/bash
# install-remote.sh

set -e

INSTALL_DIR="/opt/remote-server"
REPO_URL="https://github.com/seu-usuario/remote-server.git"

echo "📦 Instalando RSCTL remotamente..."

# Clonar ou atualizar
if [ -d "$INSTALL_DIR" ]; then
    echo "🔄 Atualizando repositório..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "📥 Clonando repositório..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Instalar CLI
echo "🔧 Instalando CLI..."
sudo ./cli/install.sh

echo "✅ Instalação concluída!"
echo ""
echo "Uso: rserver --help"
```

### Método 4: Via Docker (Futuro)

```bash
# Criar container com todos os serviços
docker build -t remote-server .
docker run -d --name remote-server remote-server

# Usar CLI dentro do container
docker exec remote-server rserver status
```

## ⚙️ Configuração Pós-Instalação

### 1. Configurar Serviços

Edite `cli/services.json` para ajustar serviços ao seu ambiente:

```bash
nano /opt/remote-server/cli/services.json
```

### 2. Configurar Permissões Sudo (Opcional)

Para evitar pedir senha sudo repetidamente:

```bash
sudo visudo

# Adicionar (substitua 'usuario' pelo seu usuário):
usuario ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/sbin/service, /usr/bin/tailscale
```

### 3. Configurar Auto-start (Opcional)

Para iniciar serviços automaticamente no boot:

```bash
# Criar systemd service
sudo tee /etc/systemd/system/remote-server.service > /dev/null << 'EOF'
[Unit]
Description=Remote Server Services
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/rserver start all
RemainAfterExit=yes
User=seu-usuario

[Install]
WantedBy=multi-user.target
EOF

# Habilitar
sudo systemctl enable remote-server.service
sudo systemctl start remote-server.service
```

## 🔧 Verificação

Após instalação, verifique:

```bash
# Verificar se rserver está instalado
which rserver

# Verificar versão/configuração
rserver --help

# Listar serviços
rserver list

# Verificar status
rserver status
```

## 🐛 Troubleshooting

### rserver não encontrado

```bash
# Verificar PATH
echo $PATH

# Adicionar ao PATH se necessário
export PATH="$PATH:/usr/local/bin"

# Ou usar caminho completo
/usr/local/bin/rserver --help
```

### Erro de permissão

```bash
# Verificar permissões
ls -l /usr/local/bin/rserver

# Corrigir se necessário
sudo chmod +x /usr/local/bin/rserver
```

### Serviços não iniciam

```bash
# Verificar logs
rserver status

# Verificar dependências
systemctl status ssh
docker ps
```

## 📝 Próximos Passos

1. **Configurar serviços** em `cli/services.json`
2. **Testar inicialização**: `rserver start all`
3. **Configurar auto-start** (opcional)
4. **Acessar remotamente** via SSH/Tailscale

## 🔐 Segurança

- Use chaves SSH em vez de senhas
- Configure firewall adequadamente
- Use Tailscale para acesso VPN
- Mantenha sistema atualizado

## 📚 Mais Informações

- [Documentação da CLI](README.md)
- [Documentação Principal](../README.md)
