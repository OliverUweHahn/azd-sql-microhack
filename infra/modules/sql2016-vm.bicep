param location string
param vmName string
param subnetId string
param privateIPAddress string
param vmSize string
param adminUsername string
param teamVmCount int

@secure()
param adminPassword string

param tags object

var ConfigureSQLFirewallCommand = 'powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "Set-FW-ForAllInstances.ps1"'
var RestoreTeamDatabasesCommand = 'powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "Restore-TeamDatabases.ps1" -TeamCount ${teamVmCount} -BackupBaseUri "https://raw.githubusercontent.com/OliverUweHahn/azd-sql-microhack/main/Databases"'


resource networkInterface 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: '${vmName}-nic'
  location: location
  tags: tags

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateIPAddress

          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: vmName
  location: location
  tags: tags

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword

      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }

    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'SQL2016SP3-WS2019'
        sku: 'sqldev'
        version: 'latest'
      }

      osDisk: {
        createOption: 'FromImage'

        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

resource installTeamTools 'Microsoft.Compute/virtualMachines/extensions@2024-11-01' = {
  parent: virtualMachine
  name: 'ConfigureSQLFirewall'
  location: location

  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true

    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/OliverUweHahn/azd-sql-microhack/main/scripts/Set-FW-ForAllInstances.ps1'
      ]
    }

    protectedSettings: {
      commandToExecute: ConfigureSQLFirewallCommand
    }
  }
}

resource RestoreTeamDatabases 'Microsoft.Compute/virtualMachines/extensions@2024-11-01' = {
  parent: virtualMachine
  name: 'RestoreTeamDatabases'
  location: location

  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true

    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/OliverUweHahn/azd-sql-microhack/main/scripts/Restore-TeamDatabases.ps1'
      ]
    }

    protectedSettings: {
      commandToExecute: RestoreTeamDatabasesCommand
    }
  }
}

output vmName string = virtualMachine.name
output privateIPAddress string = privateIPAddress
