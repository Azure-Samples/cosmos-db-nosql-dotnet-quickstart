metadata description = 'Create web application resources.'

param envName string
param appName string
param serviceTag string
param location string = resourceGroup().location
param tags object = {}

@description('Endpoint for Azure Cosmos DB for NoSQL account.')
param databaseAccountEndpoint string

@description('Unique identifier for user-assigned managed identity.')
param userAssignedManagedIdentityId string

@description('Name of the container image to deploy')
param containerImage string = ''

module containerAppsEnvironment '../core/host/container-apps/environments/managed.bicep' = {
  name: 'container-apps-env'
  params: {
    name: envName
    location: location
    tags: tags
  }
}

module containerAppsApp '../core/host/container-apps/app.bicep' = {
  name: 'container-apps-app'
  params: {
    name: appName
    parentEnvironmentName: containerAppsEnvironment.outputs.name
    location: location
    tags: union(tags, {
        'azd-service-name': serviceTag
      })
    containerImage: !empty(containerImage) ? containerImage : null
    secrets: [
      {
        name: 'azure-cosmos-db-nosql-endpoint' // Create a uniquely-named secret
        value: databaseAccountEndpoint // NoSQL database account endpoint
      }
    ]
    environmentVariables: [
      {
        name: 'AZURE_COSMOS_DB_NOSQL_ENDPOINT' // Name of the environment variable referenced in the application
        secretRef: 'azure-cosmos-db-nosql-endpoint' // Reference to secret
      }
    ]
    userAssignedManagedIdentityIds: [
      userAssignedManagedIdentityId // Associate user-assigned managed identity with this app
    ]
  }
}

output endpoint string = containerAppsApp.outputs.endpoint
output envName string = containerAppsApp.outputs.name
