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
#Start-Process `
#-FilePath "powershell.exe" `
#-Credential $cred `
#-ArgumentList "-ExecutionPolicy Bypass -File $((Get-Location).Path)\Restore-SampleDatabases.ps1 -BackupUri $BackupUri" `
#-Wait

try
{
    Start-Process `
        -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -Credential $cred `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\Restore-SampleDatabases.ps1`" -BackupUri `"$BackupUri`"" `
        -Wait `
        -ErrorAction Stop
}
catch
{
    $_ | Format-List * -Force
    throw
}

#& .\Restore-SampleDatabases.ps1 `
#    -BackupUri $BackupUri

Write-Host "Bootstrap completed."