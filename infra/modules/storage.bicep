param location string
param storageAccountName string
param tags object
param vmPrincipalId string
param sqlmiPrincipalId string

var storageBlobDataContributorRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
)

var storageBlobDataReaderRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
)

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageAccountName
  location: location
  tags: tags

  sku: {
    name: 'Standard_LRS'
  }

  kind: 'StorageV2'

  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource backupContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  name: '${storageAccount.name}/default/backups'

  properties: {
    publicAccess: 'None'
  }
}

resource vmBlobContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    storageAccount.id,
    vmPrincipalId,
    storageBlobDataContributorRoleId
  )

  scope: storageAccount

  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: vmPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource sqlmiBlobDataReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    storageAccount.id,
    sqlmiPrincipalId,
    storageBlobDataReaderRoleId
  )

  scope: storageAccount

  properties: {
    roleDefinitionId: storageBlobDataReaderRoleId
    principalId: sqlmiPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output storageAccountName string = storageAccount.name

output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
