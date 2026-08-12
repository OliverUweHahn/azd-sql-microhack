[CmdletBinding()]
param
(
    [string] $ManagedInstanceServer
)

if (-not (Test-Path -LiteralPath "C:\MicroHack"))
{
    New-Item `
        -ItemType Directory `
        -Path "C:\MicroHack" `
        -Force |
        Out-Null
}

$EnvironmentInfoPath = Join-Path $DownloadDirectory "EnvironmentInfo.txt"

if (Test-Path $EnvironmentInfoPath) {
    Remove-Item -LiteralPath $EnvironmentInfoPath -ErrorAction SilentlyContinue -Force
}

"Your Hack-Environment" | Out-File -FilePath $EnvironmentInfoPath -Encoding utf8 -Force
"" | Out-File -FilePath $EnvironmentInfoPath -Encoding utf8 -Force -Append
"SQL Managed Instance: $ManagedInstanceServer" | Out-File -FilePath $EnvironmentInfoPath -Encoding utf8 -Force -Append

$TargetFile = $EnvironmentInfoPath
$ShortcutPath = "$env:Public\Desktop\EnvironmentInfo.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetFile
$Shortcut.WorkingDirectory = Split-Path $TargetFile
$Shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,0"
$Shortcut.Save()

$Target = "C:\Program Files\Microsoft SQL Server Management Studio 22\Release\Common7\IDE\SSMS.exe"
if (Test-Path $Target) {
    $Shell = New-Object -ComObject WScript.Shell
    $Link = $Shell.CreateShortcut("$env:Public\Desktop\SSMS 22.lnk")
    $Link.TargetPath = $Target
    $Link.IconLocation = "$Target,0"
    $Link.Save()
}
