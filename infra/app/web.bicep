metadata description = 'Create Azure App Service resources.'

param planName string
param siteName string
param serviceTag string
param location string = resourceGroup().location
param tags object = {}

@description('Endpoint for Azure Cosmos DB for NoSQL account.')
param databaseAccountEndpoint string

@description('Name of the container image to deploy')
param containerImage string = 'ghcr.io/azure-samples/cosmos-db-nosql-dotnet-quickstart:main'

module containerAppsEnvironment '../core/web/container-apps/environments/managed.bicep' = {
  name: 'container-apps-env'
  params: {
    name: planName
    location: location
    tags: tags
  }
}

module containerAppsApp '../core/web/container-apps/app.bicep' = {
  name: 'container-apps-app'
  dependsOn: [
    containerAppsEnvironment
  ]
  params: {
    name: siteName
    parentEnvironmentName: containerAppsEnvironment.outputs.name
    location: location
    tags: union(tags, {
        'azd-service-name': serviceTag
      })
    containerImage: containerImage // Use container image from GitHub
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
    enableSystemAssignedManagedIdentity: true // Create system-assigned managed identity
  }
}

output endpoint string = containerAppsApp.outputs.endpoint
output siteName string = containerAppsApp.outputs.name
output siteManagedIdentityPrincipalId string = containerAppsApp.outputs.managedIdentityPrincipalId
