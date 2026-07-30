param location string
param bastionName string
param bastionSubnetId string
param tags object

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${bastionName}-pip'
  location: location
  tags: tags

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2024-05-01' = {
  name: bastionName
  location: location
  tags: tags

  sku: {
    name: 'Basic'
  }

  properties: {
    ipConfigurations: [
      {
        name: 'bastion-ip-config'
        properties: {
          subnet: {
            id: bastionSubnetId
          }

          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

output bastionName string = bastion.name
output bastionId string = bastion.id
