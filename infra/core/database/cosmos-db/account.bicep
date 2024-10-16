metadata description = 'Create an Azure Cosmos DB account.'

param name string
param location string = resourceGroup().location
param tags object = {}

@allowed([ 'GlobalDocumentDB', 'MongoDB', 'Parse' ])
@description('Sets the kind of account.')
param kind string

@description('Enables serverless for this account. Defaults to false.')
param enableServerless bool = false

@description('Disables key-based authentication. Defaults to false.')
param disableKeyBasedAuth bool = false

@description('List of capabilities for the account. Defaults to an empty array.')
param capabilities object[] = []

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
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
    disableLocalAuth: disableKeyBasedAuth
    capabilities: union(capabilities,
      (enableServerless) ? [
        {
          name: 'EnableServerless'
        }
      ] : []
    )
  }
}

output name string = account.name
