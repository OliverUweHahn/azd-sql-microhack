param(
    [int]$TeamCount = 1,
    [string]$BackupBaseUri,
    [string]$SysAdminUsername,
    [string]$SysAdminPassword
)

$ErrorActionPreference = 'Stop'

Write-Host "Configuring SQL Firewall..."
& .\Set-FW-ForAllInstances.ps1

Write-Host "Restoring Team Databases..."

& .\Restore-TeamDatabases.ps1 -TeamCount $TeamCount -BackupBaseUri $BackupBaseUri -sqlusername $SysAdminUsername -sqlpassword $SysAdminPassword

Write-Host "Bootstrap completed."