param location string
param vmName string
param subnetId string
param privateIPAddress string
param vmSize string
param adminUsername string

@secure()
param adminPassword string

param tags object

var ConfigureSQLMachineCommand = 'powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "bootstrap-newsql.ps1" -BackupUri "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak" -SysAdminUsername ${adminUsername} -SysAdminPassword ${adminPassword}'

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
        offer: 'SQL2022-WS2022'
        sku: 'sqldev-gen2'
        version: 'latest'
      }

      osDisk: {
        createOption: 'FromImage'

        managedDisk: {
          storageAccountType: 'Standard_LRS'
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

resource ConfigureSQLMachine 'Microsoft.Compute/virtualMachines/extensions@2024-11-01' = {
  parent: virtualMachine
  name: 'ConfigureSQLMachine'
  location: location

  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true

    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/OliverUweHahn/azd-sql-microhack/main/scripts/Set-FW-ForAllInstances.ps1'
        'https://raw.githubusercontent.com/OliverUweHahn/azd-sql-microhack/main/scripts/Restore-SampleDatabases.ps1'
        'https://raw.githubusercontent.com/OliverUweHahn/azd-sql-microhack/main/scripts/bootstrap-newsql.ps1'
      ]
    }

    protectedSettings: {
      commandToExecute: ConfigureSQLMachineCommand
    }
  }
}

output vmName string = virtualMachine.name
output privateIPAddress string = privateIPAddress
