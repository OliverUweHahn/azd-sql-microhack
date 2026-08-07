param location string
param teamVmCount int

var installTeamToolsCommand = 'powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "install-team-tools.ps1"'

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
          'https://raw.githubusercontent.com/OliverUweHahn/azd-sql-microhack/main/scripts/install-team-tools.ps1'
        ]
      }

      protectedSettings: {
        commandToExecute: installTeamToolsCommand
      }
    }
  }
]
