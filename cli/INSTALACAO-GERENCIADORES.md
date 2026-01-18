# 📦 Instalação via Gerenciadores de Pacotes

Este guia explica como instalar o RSERVER usando diferentes gerenciadores de pacotes.

## 🐍 PyPI (Python Package Index)

### Instalação

```bash
pip install rserver
```

### Atualização

```bash
pip install --upgrade rserver
```

### Desinstalação

```bash
pip uninstall rserver
```

### Requisitos

- Python 3.7 ou superior
- pip (geralmente já instalado com Python)

## 🍺 Homebrew (macOS e Linux)

### Opção 1: Tap Próprio (Recomendado)

```bash
# Adicionar tap
brew tap KelvinSilvaDev/rserver

# Instalar
brew install rserver
```

### Opção 2: Homebrew Core (Futuro)

Quando o RSERVER estiver no Homebrew Core:

```bash
brew install rserver
```

### Atualização

```bash
brew upgrade rserver
```

### Desinstalação

```bash
brew uninstall rserver
```

## 📦 Outros Gerenciadores (Em Desenvolvimento)

### Snap (Linux Ubuntu)

```bash
snap install rserver
```

### Chocolatey (Windows)

```powershell
choco install rserver
```

### Scoop (Windows)

```powershell
scoop install rserver
```

## ✅ Verificar Instalação

Após instalar, verifique se está funcionando:

```bash
rserver --version
rserver list
rserver status
```

## 🔧 Configuração

Após instalar, você pode precisar configurar os serviços. O arquivo de configuração padrão está em:

- **Linux/macOS**: `~/.config/rserver/services.json`
- **Windows**: `%APPDATA%/rserver/services.json`

Você pode copiar o arquivo de exemplo do repositório:

```bash
# Linux/macOS
mkdir -p ~/.config/rserver
curl -o ~/.config/rserver/services.json \
  https://raw.githubusercontent.com/KelvinSilvaDev/rserver/main/cli/services.json

# Windows (PowerShell)
New-Item -ItemType Directory -Force -Path "$env:APPDATA\rserver"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KelvinSilvaDev/rserver/main/cli/services.json" \
  -OutFile "$env:APPDATA\rserver\services.json"
```

## 🐛 Problemas Comuns

### Comando não encontrado

Se o comando `rserver` não for encontrado após a instalação:

1. **PyPI**: Verifique se o diretório de scripts do Python está no PATH
   ```bash
   # Adicionar ao PATH (Linux/macOS)
   export PATH="$HOME/.local/bin:$PATH"
   
   # Adicionar ao PATH (Windows)
   # Adicione %USERPROFILE%\AppData\Local\Programs\Python\PythonXX\Scripts ao PATH
   ```

2. **Homebrew**: Verifique se o Homebrew está configurado corretamente
   ```bash
   brew doctor
   ```

### Erro ao carregar configuração

Se você receber um erro sobre arquivo de configuração não encontrado:

1. Crie o diretório de configuração (veja seção Configuração acima)
2. Ou especifique um arquivo de configuração customizado:
   ```bash
   rserver --config /caminho/para/services.json status
   ```

## 📚 Próximos Passos

Após instalar, consulte:

- **[Documentação Completa](../DOCUMENTACAO.md)** - Guia completo de uso
- **[Quick Start](QUICK-START.md)** - Início rápido
- **[README Principal](../README.md)** - Visão geral do projeto

---

**Precisa de ajuda?** Abra uma [issue](https://github.com/KelvinSilvaDev/rserver/issues) no GitHub!
