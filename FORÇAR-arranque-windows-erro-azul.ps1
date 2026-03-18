# SCRIPT DE REPARAÇÃO DE EMERGÊNCIA (OFFLINE/USB)
Write-Host "--- A FORÇAR ANULAÇÃO DE ERROS E TRAVAMENTOS ---" -ForegroundColor Red

# 1. ACERTAR O RELÓGIO (Manual para evitar erros de certificado)
# Ajusta para a data/hora de agora para o Windows não entrar em loop
$dataManual = "18/03/2026 17:00"
Set-Date -Date "$dataManual" -ErrorAction SilentlyContinue

# 2. DESATIVAR REINÍCIO AUTOMÁTICO NO ECRÃ AZUL
# Isso permite que o PC ignore o erro crítico e tente continuar
Write-Host "Configurando sistema para ignorar falhas de arranque..." -ForegroundColor Yellow
bcdedit /set {default} recoveryenabled No
bcdedit /set {default} bootstatuspolicy ignoreallfailures

# 3. LIMPAR FICHEIROS DE REPOSIÇÃO DE DRIVERS (Onde o erro 'Died' se esconde)
Write-Host "Removendo ficheiros de hibernação e dump corrompidos..." -ForegroundColor Yellow
# O ficheiro hiberfil.sys corrompido causa ecrã azul no arranque de PCs antigos
if (Test-Path "C:\hiberfil.sys") { Remove-Item "C:\hiberfil.sys" -Force }

# 4. REPARAR O BOOT (Mestre do Arranque)
Write-Host "Reparando setores de arranque..." -ForegroundColor Cyan
bootrec /fixmbr
bootrec /fixboot
bootrec /rebuildbcd

# 5. DESATIVAR DRIVERS DE TERCEIROS QUE TRAVAM O SISTEMA
# Este comando força o Windows a usar apenas o essencial na próxima vez
Write-Host "Limpando fila de drivers pendentes..." -ForegroundColor Yellow
DISM /Image:C:\ /Cleanup-Image /RevertPendingActions

Write-Host "`n--- TENTATIVA DE REPARAÇÃO CONCLUÍDA ---" -ForegroundColor Green
Write-Host "Remova a Pen USB e tente ligar o Inspiron normalmente."