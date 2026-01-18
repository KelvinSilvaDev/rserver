# =============================================================================
# 📦 INSTALAÇÃO DO RSERVER - Remote Server Control
# Windows PowerShell Script
# =============================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       📦 INSTALAÇÃO DO RSERVER - Remote Server Control         ║" -ForegroundColor Cyan
Write-Host "║                      Windows                                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Detectar diretório do projeto
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Write-Host "📂 Diretório do projeto: $ProjectDir" -ForegroundColor Yellow
Write-Host ""

# Verificar Python 3
Write-Host "🐍 Verificando Python 3..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Python não encontrado"
    }
    Write-Host "✅ $pythonVersion encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Python 3 não encontrado." -ForegroundColor Red
    Write-Host "   Instale Python 3 de: https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "   Certifique-se de marcar 'Add Python to PATH' durante a instalação" -ForegroundColor Yellow
    exit 1
}

# Verificar versão mínima (3.7+)
$pythonMajor = python -c "import sys; print(sys.version_info.major)" 2>&1
$pythonMinor = python -c "import sys; print(sys.version_info.minor)" 2>&1
if ([int]$pythonMajor -lt 3 -or ([int]$pythonMajor -eq 3 -and [int]$pythonMinor -lt 7)) {
    Write-Host "❌ Python 3.7+ é necessário. Versão atual: $pythonVersion" -ForegroundColor Red
    exit 1
}

# Diretório de instalação (Scripts do Python ou AppData Local)
$PythonDir = Split-Path -Parent (Get-Command python).Source
$InstallDir = Join-Path $PythonDir "Scripts"

# Verificar se Scripts existe, senão usar AppData
if (-not (Test-Path $InstallDir)) {
    $InstallDir = Join-Path $env:LOCALAPPDATA "Programs\rserver"
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
}

Write-Host "📂 Diretório de instalação: $InstallDir" -ForegroundColor Yellow
Write-Host ""

# Criar diretório se não existir
if (-not (Test-Path $InstallDir)) {
    Write-Host "📁 Criando diretório $InstallDir..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# Nome do CLI
$CLIName = "rserver"
$BackupName = "rsctl"

# Verificar se já existe
$CLIPath = Join-Path $InstallDir "$CLIName.bat"
if (Test-Path $CLIPath) {
    $response = Read-Host "⚠️  $CLIName já existe. Deseja sobrescrever? (s/N)"
    if ($response -notmatch "^[SsYy]$") {
        Write-Host "⏭️  Instalação cancelada" -ForegroundColor Yellow
        exit 0
    }
    Remove-Item $CLIPath -Force
}

# Criar wrapper batch script
Write-Host "🔗 Criando script de instalação..." -ForegroundColor Yellow

$BatchContent = @"
@echo off
REM Wrapper para rsctl_new.py (versão refatorada)
python "$ProjectDir\cli\rsctl_new.py" %*
"@

$BatchContent | Out-File -FilePath $CLIPath -Encoding ASCII
Write-Host "✅ Script criado: $CLIPath" -ForegroundColor Green

# Criar também rsctl para compatibilidade
$BackupPath = Join-Path $InstallDir "$BackupName.bat"
if (-not (Test-Path $BackupPath)) {
    $BackupContent = @"
@echo off
REM Wrapper para rsctl.py (versão legada - compatibilidade)
python "$ProjectDir\cli\rsctl.py" %*
"@
    $BackupContent | Out-File -FilePath $BackupPath -Encoding ASCII
    Write-Host "✅ Script de compatibilidade criado: $BackupPath" -ForegroundColor Green
}

# Verificar PATH
$PathEnv = [Environment]::GetEnvironmentVariable("Path", "User")
if ($PathEnv -notlike "*$InstallDir*") {
    Write-Host ""
    Write-Host "⚠️  $InstallDir não está no PATH do usuário" -ForegroundColor Yellow
    Write-Host "   Adicione manualmente ou execute:" -ForegroundColor Yellow
    Write-Host "   [Environment]::SetEnvironmentVariable('Path', `"`$env:Path;$InstallDir`", 'User')" -ForegroundColor Cyan
    Write-Host ""
    $response = Read-Host "Deseja adicionar ao PATH automaticamente? (s/N)"
    if ($response -match "^[SsYy]$") {
        [Environment]::SetEnvironmentVariable("Path", "$PathEnv;$InstallDir", "User")
        Write-Host "✅ Adicionado ao PATH do usuário" -ForegroundColor Green
        Write-Host "   ⚠️  Feche e reabra o terminal para aplicar as mudanças" -ForegroundColor Yellow
    }
}

# Verificar instalação
Write-Host ""
Write-Host "🧪 Testando instalação..." -ForegroundColor Yellow

if (Test-Path $CLIPath) {
    Write-Host "✅ $CLIName instalado com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📖 Uso:" -ForegroundColor Cyan
    Write-Host "   $CLIName list              # Lista serviços disponíveis"
    Write-Host "   $CLIName status            # Mostra status de todos os serviços"
    Write-Host "   $CLIName start all         # Inicia todos os serviços"
    Write-Host "   $CLIName start ssh ollama   # Inicia serviços específicos"
    Write-Host "   $CLIName stop webui         # Para um serviço"
    Write-Host ""
    Write-Host "✅ Instalação concluída!" -ForegroundColor Green
    Write-Host "💡 Dica: Use '$CLIName' como comando principal" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⚠️  Nota: Se o comando não for encontrado, feche e reabra o terminal" -ForegroundColor Yellow
} else {
    Write-Host "❌ Erro: $CLIName não encontrado após instalação" -ForegroundColor Red
    Write-Host "   Tente executar: $CLIPath --help" -ForegroundColor Yellow
    exit 1
}
