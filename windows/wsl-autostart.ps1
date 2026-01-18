# =============================================================================
# 🔄 Iniciar WSL automaticamente com Windows
# =============================================================================
# Execute como Administrador

Write-Host "⚙️ Configurando WSL para iniciar com Windows..." -ForegroundColor Cyan

# Criar tarefa agendada
$action = New-ScheduledTaskAction -Execute "wsl.exe" -Argument "-d Ubuntu -u kelvin ~/remote-server/wsl-startup.sh"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "WSL Remote Server" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force

Write-Host "✅ Tarefa agendada criada!" -ForegroundColor Green
Write-Host ""
Write-Host "O WSL iniciará automaticamente quando você fizer login no Windows." -ForegroundColor Yellow

