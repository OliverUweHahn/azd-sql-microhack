param(
    [string]$BackupUri
)

$ErrorActionPreference = 'Stop'

Write-Host "Configuring SQL Firewall..."
& .\Set-FW-ForAllInstances.ps1

Write-Host "Restoring Sample Database..."
& .\Restore-SampleDatabases.ps1 `
    -BackupUri $BackupUri

Write-Host "Bootstrap completed."