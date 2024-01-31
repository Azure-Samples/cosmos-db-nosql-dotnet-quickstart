metadata description = 'Create an Azure Cosmos DB for NoSQL account.'

param name string
param location string = resourceGroup().location
param tags object = {}

@description('Enables serverless for this account. Defaults to false.')
param enableServerless bool = false

@description('Disables key-based authentication to the data plane. Defaults to false.')
param disableKeyBasedDataPlaneAuth bool = false

@description('Disables key-based authentication to the control plane. Defaults to false.')
param disableKeyBasedControlPlaneAuth bool = false

module account '../account.bicep' = {
  name: 'cosmos-db-nosql-account'
  params: {
    name: name
    location: location
    tags: tags
    kind: 'GlobalDocumentDB'
    enableServerless: enableServerless
    disableKeyBasedControlPlaneAuth: disableKeyBasedDataPlaneAuth
    disableKeyBasedDataPlaneAuth: disableKeyBasedControlPlaneAuth
  }
}

output endpoint string = account.outputs.endpoint
output name string = account.outputs.name
