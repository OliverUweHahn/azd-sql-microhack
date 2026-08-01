param(
    [int]$TeamCount = 1,
    [string]$BackupBaseUri
)

$ErrorActionPreference = 'Stop'

Write-Host "Configuring SQL Firewall..."
& .\Set-FW-ForAllInstances.ps1

Write-Host "Restoring Team Databases..."
& .\Restore-TeamDatabases.ps1 `
    -TeamCount $TeamCount `
    -BackupBaseUri $BackupBaseUri

Write-Host "Bootstrap completed."