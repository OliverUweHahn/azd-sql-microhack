param location string
param teamVmCount int
param reproBaseURL string

var ConfigureTeamVMCommand = 'powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "bootstrap-teamvm.ps1" -SamplesBaseUri "${reproBaseURL}/TSQL_Scripts" -WallpaperUri "${reproBaseURL}/assets/BaseWallpaper.jpg" -TeamNumber ##teamNumber##'

resource virtualMachines 'Microsoft.Compute/virtualMachines@2024-11-01' existing = [
  for index in range(0, teamVmCount): {
    name: 'vm-TEAM${padLeft(string(index + 1), 2, '0')}'
  }
]

resource installTeamTools 'Microsoft.Compute/virtualMachines/extensions@2024-11-01' = [
  for index in range(0, teamVmCount): {

    parent: virtualMachines[index]
    name: 'install-team-tools'
    location: location

    properties: {
      publisher: 'Microsoft.Compute'
      type: 'CustomScriptExtension'
      typeHandlerVersion: '1.10'
      autoUpgradeMinorVersion: true

      settings: {
        fileUris: [
          '${reproBaseURL}/scripts/install-team-tools.ps1'
          '${reproBaseURL}/scripts/Download-Samples.ps1'
          '${reproBaseURL}/scripts/bootstrap-teamvm.ps1'
          '${reproBaseURL}/scripts/Configure-TeamWallpaper.ps1'
        ]
      }

      protectedSettings: {
        commandToExecute: replace(ConfigureTeamVMCommand, '##teamNumber##', string(index + 1))
      }
    }
  }
]
