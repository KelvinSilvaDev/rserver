# =============================================================================
# 🌐 Instalar Tailscale no Windows
# =============================================================================
# Execute como Administrador no PowerShell

Write-Host "🌐 Instalando Tailscale no Windows..." -ForegroundColor Cyan

# Baixar instalador
$installerUrl = "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe"
$installerPath = "$env:TEMP\tailscale-setup.exe"

Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Instalar silenciosamente
Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait

Write-Host "✅ Tailscale instalado!" -ForegroundColor Green
Write-Host ""
Write-Host "Agora:" -ForegroundColor Yellow
Write-Host "1. Abra o Tailscale no menu iniciar"
Write-Host "2. Clique em 'Log in'"
Write-Host "3. Use a mesma conta do WSL"

