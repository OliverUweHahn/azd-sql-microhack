targetScope = 'subscription'

@minLength(1)
@maxLength(20)
param environmentName string

param location string

param adminUsername string

@secure()
param adminPassword string

param sqlMiAdminUsername string

@secure()
param sqlMiAdminPassword string

@minValue(5)
@maxValue(20)
param teamVmCount int = 5

param vnetAddressPrefix string = '10.0.0.0/16'
param managedInstanceSubnetPrefix string = '10.0.1.0/24'
param managementSubnetPrefix string = '10.0.2.0/24'
param teamSubnetPrefix string = '10.0.3.0/24'
param bastionSubnetPrefix string = '10.0.4.0/24'

param legacyVmSize string = 'Standard_D4s_v5'
param teamVmSize string = 'Standard_D2s_v5'

param managedInstanceVCores int = 8
param managedInstanceStorageGB int = 256

param tags object = {
  workload: 'SQL Modernization MicroHack'
  environment: environmentName
  managedBy: 'azd-bicep'
}

var suffix = uniqueString(
  subscription().subscriptionId,
  environmentName,
  location
)

var resourceGroupName = 'rg-${environmentName}'
var vnetName = 'SQLHACK-SHARED-VNET'
var managedInstanceName = 'sqlmi-${environmentName}-${suffix}'

var storageAccountName = take(
  toLower(
    replace(
      'sqlhack${environmentName}${suffix}',
      '-',
      ''
    )
  ),
  24
)

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module network 'modules/network.bicep' = {
  name: 'network'
  scope: resourceGroup
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    managedInstanceSubnetPrefix: managedInstanceSubnetPrefix
    managementSubnetPrefix: managementSubnetPrefix
    teamSubnetPrefix: teamSubnetPrefix
    bastionSubnetPrefix: bastionSubnetPrefix
    tags: tags
  }
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    location: location
    storageAccountName: storageAccountName
    tags: tags
  }
}

module bastion 'modules/bastion.bicep' = {
  name: 'bastion'
  scope: resourceGroup
  params: {
    location: location
    bastionName: 'bas-${environmentName}'
    bastionSubnetId: network.outputs.bastionSubnetId
    tags: tags
  }
}

module legacySqlVm 'modules/sql2016-vm.bicep' = {
  name: 'legacy-sql-vm'
  scope: resourceGroup
  params: {
    location: location
    vmName: 'LegacySQL2016'
    subnetId: network.outputs.managementSubnetId
    privateIPAddress: '10.0.2.5'
    vmSize: legacyVmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags
  }
}

module teamVms 'modules/team-vms.bicep' = {
  name: 'team-vms'
  scope: resourceGroup
  params: {
    location: location
    teamVmCount: teamVmCount
    subnetId: network.outputs.teamSubnetId
    vmSize: teamVmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags
  }
}

module managedInstance 'modules/managed-instance.bicep' = {
  name: 'managed-instance'
  scope: resourceGroup
  params: {
    location: location
    managedInstanceName: managedInstanceName
    subnetId: network.outputs.managedInstanceSubnetId
    administratorLogin: sqlMiAdminUsername
    administratorLoginPassword: sqlMiAdminPassword
    vCores: managedInstanceVCores
    storageSizeInGB: managedInstanceStorageGB
    tags: tags
  }
}

output AZURE_RESOURCE_GROUP string = resourceGroup.name
output AZURE_LOCATION string = location

output AZURE_STORAGE_ACCOUNT_NAME string = storage.outputs.storageAccountName

output SQL_MI_NAME string = managedInstance.outputs.managedInstanceName

output SQL_MI_FQDN string = managedInstance.outputs.fullyQualifiedDomainName

output LEGACY_SQL_VM_NAME string = legacySqlVm.outputs.vmName

output TEAM_VM_NAMES array = teamVms.outputs.vmNames

output BASTION_NAME string = bastion.outputs.bastionName
