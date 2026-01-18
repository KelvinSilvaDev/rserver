# 🌐 Suporte Multiplataforma

RSERVER é uma CLI multiplataforma que funciona em **Linux**, **macOS** e **Windows**.

## 📋 Plataformas Suportadas

| Plataforma | Versão Mínima | Status | Notas |
|------------|---------------|--------|-------|
| **Linux** | Qualquer distribuição moderna | ✅ Totalmente Suportado | Ubuntu, Debian, RHEL, Arch, etc. |
| **macOS** | 10.14+ (Mojave) | ✅ Totalmente Suportado | Intel e Apple Silicon (M1/M2) |
| **Windows** | Windows 10+ | ✅ Suportado | PowerShell 5.1+ ou PowerShell Core |

## 🚀 Instalação por Plataforma

### Linux

```bash
# Método 1: Instalação Global (recomendado)
sudo ./cli/install.sh

# Método 2: Instalação do Usuário (sem sudo)
INSTALL_DIR=~/.local/bin ./cli/install.sh

# Verificar
rserver --help
```

**Distribuições testadas:**
- Ubuntu 20.04+
- Debian 10+
- RHEL/CentOS 8+
- Arch Linux
- Fedora

### macOS

```bash
# Método 1: Instalação Global (recomendado)
sudo ./cli/install.sh

# Método 2: Instalação do Usuário (sem sudo)
INSTALL_DIR=~/.local/bin ./cli/install.sh

# Verificar
rserver --help
```

**Requisitos:**
- Python 3.7+ (via Homebrew ou python.org)
- Terminal (Terminal.app, iTerm2, etc.)

**Instalar Python (se necessário):**
```bash
# Via Homebrew
brew install python3

# Ou baixar de python.org
# https://www.python.org/downloads/
```

### Windows

#### PowerShell (Recomendado)

```powershell
# Executar como Administrador (opcional, para instalação global)
# Ou como usuário normal (instalação local)

# Navegar até o diretório do projeto
cd C:\caminho\para\remote-server

# Executar script de instalação
.\cli\install.ps1
```

**Requisitos:**
- Python 3.7+ instalado
- PowerShell 5.1+ ou PowerShell Core
- Python adicionado ao PATH

**Instalar Python:**
1. Baixe de: https://www.python.org/downloads/
2. **Importante:** Marque "Add Python to PATH" durante instalação
3. Reinicie o terminal após instalação

**Se o script não executar:**
```powershell
# Permitir execução de scripts (uma vez)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Depois execute o install.ps1
.\cli\install.ps1
```

#### CMD (Alternativo)

```cmd
REM Navegar até o diretório
cd C:\caminho\para\remote-server

REM Executar via PowerShell
powershell -ExecutionPolicy Bypass -File .\cli\install.ps1
```

## 🔍 Verificação de Instalação

### Linux/macOS

```bash
# Verificar se está instalado
which rserver

# Testar
rserver --version
rserver --help
rserver list
```

### Windows

```powershell
# Verificar se está instalado
Get-Command rserver

# Testar
rserver --version
rserver --help
rserver list
```

## ⚙️ Diferenças entre Plataformas

### Comandos do Sistema

Alguns comandos podem variar entre plataformas:

| Funcionalidade | Linux | macOS | Windows |
|----------------|-------|-------|---------|
| **Verificar processo** | `pgrep` | `pgrep` | `tasklist` / PowerShell |
| **Verificar porta** | `ss -lntp` | `lsof` | `netstat` |
| **Gerenciar serviços** | `systemctl` | `launchctl` | `sc` / PowerShell |
| **Sudo** | `sudo` | `sudo` | Não necessário (UAC) |

### Configuração de Serviços

A configuração em `services.json` permite definir comandos específicos por plataforma:

```json
{
  "services": {
    "meu-servico": {
      "display_name": "Meu Serviço",
      "check_type": "process",
      "process_name": "meu-processo",
      "start_cmd_linux": ["systemctl", "start", "servico"],
      "start_cmd_macos": ["launchctl", "load", "/path/to/plist"],
      "start_cmd_windows": ["net", "start", "Servico"],
      "start_cmd": ["comando", "universal"]  // Fallback
    }
  }
}
```

## 🐛 Troubleshooting por Plataforma

### Linux

**Problema: Comando não encontrado**
```bash
# Verificar PATH
echo $PATH

# Adicionar ao PATH
export PATH="$PATH:/usr/local/bin"
# Ou adicionar ao ~/.bashrc
echo 'export PATH="$PATH:/usr/local/bin"' >> ~/.bashrc
```

**Problema: Permissão negada**
```bash
# Usar instalação do usuário
INSTALL_DIR=~/.local/bin ./cli/install.sh
```

### macOS

**Problema: Python não encontrado**
```bash
# Instalar via Homebrew
brew install python3

# Ou verificar instalação
which python3
python3 --version
```

**Problema: Permissão negada em /usr/local/bin**
```bash
# Usar instalação do usuário
INSTALL_DIR=~/.local/bin ./cli/install.sh

# Ou corrigir permissões
sudo chown -R $(whoami) /usr/local/bin
```

### Windows

**Problema: Script não executa**
```powershell
# Permitir execução
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Problema: Python não encontrado**
```powershell
# Verificar instalação
python --version

# Se não funcionar, reinstalar Python e marcar "Add to PATH"
# https://www.python.org/downloads/
```

**Problema: Comando não encontrado após instalação**
```powershell
# Verificar PATH
$env:Path

# Adicionar manualmente
[Environment]::SetEnvironmentVariable('Path', "$env:Path;C:\Python\Scripts", 'User')

# Fechar e reabrir terminal
```

## 📝 Notas Importantes

### Compatibilidade de Serviços

Nem todos os tipos de serviços funcionam em todas as plataformas:

- **systemd**: Apenas Linux (distribuições modernas)
- **launchctl**: Apenas macOS
- **Windows Services**: Apenas Windows
- **docker**: Funciona em todas (se Docker instalado)
- **http**: Funciona em todas
- **port**: Funciona em todas (comandos diferentes)
- **process**: Funciona em todas (comandos diferentes)

### Sudo/Elevação

- **Linux/macOS**: Usa `sudo` quando necessário (configurável)
- **Windows**: Usa UAC (User Account Control) quando necessário
- **Instalação do usuário**: Não precisa elevação (recomendado)

### Caminhos

- **Linux/macOS**: Usa `/` como separador
- **Windows**: Usa `\` como separador
- **Código**: Usa `pathlib.Path` para compatibilidade automática

## 🔧 Desenvolvimento Multiplataforma

### Testar em Múltiplas Plataformas

```bash
# Linux
docker run -it ubuntu:22.04 bash
# Instalar Python e testar

# macOS
# Usar máquina física ou VM

# Windows
# Usar WSL2, VM, ou máquina física
```

### CI/CD Multiplataforma

O projeto deve ter testes em:
- GitHub Actions (Linux, macOS, Windows)
- Ou similar (GitLab CI, etc.)

## 📚 Mais Informação

- **[Instalação Detalhada](cli/INSTALL-REMOTE.md)** - Guia completo de instalação
- **[Contribuindo](CONTRIBUTING.md)** - Como contribuir para o projeto
- **[Documentação Completa](DOCUMENTACAO.md)** - Referência completa

---

**RSERVER funciona em qualquer sistema operacional moderno!** 🚀
