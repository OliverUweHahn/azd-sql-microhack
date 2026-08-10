param(
    [string]$SamplesBaseUri,
    #[string]$WallpaperUri,  
    [int]$TeamNumber
)

$ErrorActionPreference = 'Stop'

Write-Host "Configuring TEAM VM..."

#Not working with Bastion, so we will not set wallpaper for now.  If you want to set wallpaper, you can run the following command after you RDP into the VM.
#Write-Host "Configure Team Wallpaper..."
#& .\Configure-TeamWallpaper.ps1 -WallpaperUri $WallpaperUri -TeamNumber $TeamNumber

Write-Host "Installing Team Tools..."
& .\install-team-tools.ps1

Write-Host "Downloading Sample Files..."

& .\Download-Samples.ps1 -SamplesBaseUri $SamplesBaseUri -ForceDownload

Write-Host "Bootstrap completed."