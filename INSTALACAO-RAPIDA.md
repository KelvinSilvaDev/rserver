# ⚡ Instalação Rápida - RSERVER

## 🌐 Escolha Sua Plataforma

### Linux

```bash
# Instalação global (recomendado)
sudo ./cli/install.sh

# Instalação do usuário (sem sudo)
INSTALL_DIR=~/.local/bin ./cli/install.sh

# Verificar
rserver --help
```

### macOS

```bash
# Instalação global (recomendado)
sudo ./cli/install.sh

# Instalação do usuário (sem sudo)
INSTALL_DIR=~/.local/bin ./cli/install.sh

# Verificar
rserver --help
```

**Requisito:** Python 3.7+ (instale via `brew install python3` se necessário)

### Windows

```powershell
# Executar no PowerShell
.\cli\install.ps1

# Verificar
rserver --help
```

**Requisitos:**
- Python 3.7+ (baixe de python.org)
- Marque "Add Python to PATH" durante instalação
- PowerShell 5.1+ ou PowerShell Core

**Se o script não executar:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\cli\install.ps1
```

## ✅ Verificação

### Linux/macOS

```bash
which rserver
rserver --version
rserver list
```

### Windows

```powershell
Get-Command rserver
rserver --version
rserver list
```

## 🐛 Problemas?

- **Linux/macOS**: Veja [PLATAFORMAS.md](PLATAFORMAS.md#linux)
- **Windows**: Veja [PLATAFORMAS.md](PLATAFORMAS.md#windows)
- **Geral**: Veja [DOCUMENTACAO.md](DOCUMENTACAO.md#troubleshooting)

## 📚 Próximos Passos

1. **[Documentação Completa](DOCUMENTACAO.md)** - Aprenda a usar
2. **[Quick Start](cli/QUICK-START.md)** - Comandos básicos
3. **[Contribuindo](CONTRIBUTING.md)** - Ajude a melhorar o projeto

---

**RSERVER funciona em qualquer sistema operacional!** 🚀
