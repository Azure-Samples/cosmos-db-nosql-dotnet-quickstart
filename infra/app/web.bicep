metadata description = 'Create web application resources.'

param envName string
param webAppName string
param webServiceTag string
param apiAppName string
param apiServiceTag string
param location string = resourceGroup().location
param tags object = {}

@description('Endpoint for Azure Cosmos DB for NoSQL account.')
param databaseAccountEndpoint string

type managedIdentity = {
  resourceId: string
  clientId: string
}

@description('Unique identifier for user-assigned managed identity.')
param userAssignedManagedIdentity managedIdentity

module containerAppsEnvironment '../core/host/container-apps/environments/managed.bicep' = {
  name: 'container-apps-env'
  params: {
    name: envName
    location: location
    tags: tags
  }
}

module containerAppsApiApp '../core/host/container-apps/app.bicep' = {
  name: 'container-apps-api-app'
  params: {
    name: apiAppName
    parentEnvironmentName: containerAppsEnvironment.outputs.name
    location: location
    tags: union(tags, {
        'azd-service-name': apiServiceTag
      })
    secrets: [
      {
        name: 'azure-cosmos-db-nosql-endpoint' // Create a uniquely-named secret
        value: databaseAccountEndpoint // NoSQL database account endpoint
      }
      {
        name: 'azure-managed-identity-client-id' // Create a uniquely-named secret
        value: userAssignedManagedIdentity.clientId // Client ID of user-assigned managed identity
      }
    ]
    environmentVariables: [
      {
        name: 'AZURE_COSMOS_DB_NOSQL_ENDPOINT' // Name of the environment variable referenced in the application
        secretRef: 'azure-cosmos-db-nosql-endpoint' // Reference to secret
      }
      {
        name: 'AZURE_CLIENT_ID' // Name of the environment variable referenced in the application
        secretRef: 'azure-managed-identity-client-id' // Reference to secret
      }
    ]
    ingressEnabled: true
    externalAccess: false
    targetPort: 8000
    enableSystemAssignedManagedIdentity: false
    userAssignedManagedIdentityIds: [
      userAssignedManagedIdentity.resourceId
    ]
  }
}

module containerAppsWebApp '../core/host/container-apps/app.bicep' = {
  name: 'container-apps-web-app'
  params: {
    name: webAppName
    parentEnvironmentName: containerAppsEnvironment.outputs.name
    location: location
    tags: union(tags, {
        'azd-service-name': webServiceTag
      })
    secrets: [
      {
        name: 'base-api-url' // Create a uniquely-named secret
        value: containerAppsApiApp.outputs.endpoint // Endpoint to API app
      }
    ]
    environmentVariables: [
      {
        name: 'BASE_API_ENDPOINT' // Name of the environment variable referenced in the application
        secretRef: 'base-api-url' // Reference to secret
      }
    ]
    ingressEnabled: true
    externalAccess: true
    targetPort: 8000
  }
}

output endpoint string = containerAppsWebApp.outputs.endpoint
output envName string = containerAppsEnvironment.outputs.name
