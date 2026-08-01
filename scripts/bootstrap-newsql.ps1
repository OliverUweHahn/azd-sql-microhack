param(
    [string]$BackupUri,
    [string]$SysAdminUsername,
    [string]$SysAdminPassword    
)

$ErrorActionPreference = 'Stop'

Start-Sleep -Seconds 60

Write-Host "Configuring SQL Firewall..."
& .\Set-FW-ForAllInstances.ps1

Start-Sleep -Seconds 120

Write-Host "Restoring Sample Database..."

$username = $SysAdminUsername
$password = ConvertTo-SecureString $SysAdminPassword -AsPlainText -Force
$cred = New-Object PSCredential($username,$password)
Start-Process `
-FilePath "powershell.exe" `
-Credential $cred `
-ArgumentList "-ExecutionPolicy Bypass -File $((Get-Location).Path)\Restore-SampleDatabases.ps1 -BackupUri $BackupUri" `
-Wait


#& .\Restore-SampleDatabases.ps1 `
#    -BackupUri $BackupUri

Write-Host "Bootstrap completed."