param(
    [int]$TeamCount = 1,
    [string]$BackupBaseUri
)

$ErrorActionPreference = 'Stop'

Start-Sleep -Seconds 60

Write-Host "Configuring SQL Firewall..."
& .\Set-FW-ForAllInstances.ps1

Start-Sleep -Seconds 120

Write-Host "Restoring Team Databases..."
& .\Restore-TeamDatabases.ps1 `
    -TeamCount $TeamCount `
    -BackupBaseUri $BackupBaseUri

Write-Host "Bootstrap completed."