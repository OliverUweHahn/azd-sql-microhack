param(
    [string]$SamplesBaseUri,
    [string]$WallpaperUri,  
    [int]$TeamNumber
)

$ErrorActionPreference = 'Stop'

Write-Host "Configuring TEAM VM..."

Write-Host "Configure Team Wallpaper..."
& .\Configure-TeamWallpaper.ps1 -WallpaperUri $WallpaperUri -TeamNumber $TeamNumber

Write-Host "Installing Team Tools..."
& .\install-team-tools.ps1

Write-Host "Downloading Sample Files..."

& .\Download-Samples.ps1 -SamplesBaseUri $SamplesBaseUri -ForceDownload

Write-Host "Bootstrap completed."