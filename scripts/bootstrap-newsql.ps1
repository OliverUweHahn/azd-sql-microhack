param(
    [string]$BackupUri
)

$ErrorActionPreference = 'Stop'

Start-Sleep -Seconds 60

Write-Host "Configuring SQL Firewall..."
& .\Set-FW-ForAllInstances.ps1

Start-Sleep -Seconds 120

Write-Host "Restoring Sample Database..."
& .\Restore-SampleDatabases.ps1 `
    -BackupUri $BackupUri

Write-Host "Bootstrap completed."