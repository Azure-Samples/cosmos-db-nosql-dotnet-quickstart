metadata description = 'Create an Azure Cosmos DB account.'

param name string
param location string = resourceGroup().location
param tags object = {}

@allowed([ 'GlobalDocumentDB', 'MongoDB', 'Parse' ])
@description('Sets the kind of account.')
param kind string

@description('Enables serverless for this account. Defaults to false.')
param enableServerless bool = false

@description('Disables key-based authentication to the data plane. Defaults to false.')
param disableKeyBasedDataPlaneAuth bool = false

@description('Disables key-based authentication to the control plane. Defaults to false.')
param disableKeyBasedControlPlaneAuth bool = false

resource account 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    apiProperties: (kind == 'MongoDB') ? {
      serverVersion: '4.2'
    } : {}
    disableLocalAuth: disableKeyBasedDataPlaneAuth
    disableKeyBasedMetadataWriteAccess: disableKeyBasedControlPlaneAuth
    capabilities: (enableServerless) ? [
      {
        name: 'EnableServerless'
      }
    ] : []
  }
}

output endpoint string = account.properties.documentEndpoint
output name string = account.name
