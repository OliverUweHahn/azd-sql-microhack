param location string

@minValue(3)
@maxValue(20)
param teamVmCount int

param subnetId string
param vmSize string
param adminUsername string

@secure()
param adminPassword string

param tags object

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2024-05-01' = [
  for index in range(0, teamVmCount): {
    name: 'vm-TEAM${padLeft(string(index + 1), 2, '0')}-nic'
    location: location
    tags: tags

    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            privateIPAllocationMethod: 'Dynamic'

            subnet: {
              id: subnetId
            }
          }
        }
      ]
    }
  }
]

resource virtualMachines 'Microsoft.Compute/virtualMachines@2024-11-01' = [
  for index in range(0, teamVmCount): {
    name: 'vm-TEAM${padLeft(string(index + 1), 2, '0')}'
    location: location

    tags: union(
      tags,
      {
        teamNumber: string(index + 1)
      }
    )

    properties: {
      hardwareProfile: {
        vmSize: vmSize
      }

      osProfile: {
        computerName: 'TEAM${padLeft(string(index + 1), 2, '0')}'
        adminUsername: adminUsername
        adminPassword: adminPassword

        windowsConfiguration: {
          provisionVMAgent: true
          enableAutomaticUpdates: true
        }
      }

      storageProfile: {
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: '2022-datacenter-g2'
          version: 'latest'
        }

        osDisk: {
          createOption: 'FromImage'

          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
        }
      }

      networkProfile: {
        networkInterfaces: [
          {
            id: networkInterfaces[index].id
          }
        ]
      }
    }
  }
]

output vmNames array = [for index in range(0, teamVmCount): virtualMachines[index].name]
