param(
    [int]$TeamCount = 1,
    [string]$BackupBaseUri,
    [string]$SysAdminUsername,
    [string]$SysAdminPassword
)

$ErrorActionPreference = 'Stop'

Start-Sleep -Seconds 60

Write-Host "Configuring SQL Firewall..."
& .\Set-FW-ForAllInstances.ps1

Start-Sleep -Seconds 120

Write-Host "Restoring Team Databases..."

$username = $SysAdminUsername
$password = ConvertTo-SecureString $SysAdminPassword -AsPlainText -Force
$cred = New-Object PSCredential($username,$password)
Start-Process `
-FilePath "powershell.exe" `
-Credential $cred `
-ArgumentList "-ExecutionPolicy Bypass -File $((Get-Location).Path)\Restore-TeamDatabases.ps1 -TeamCount $TeamCount -BackupBaseUri $BackupBaseUri" `
-Wait

#& .\Restore-TeamDatabases.ps1 `
#    -TeamCount $TeamCount `
#    -BackupBaseUri $BackupBaseUri

Write-Host "Bootstrap completed."