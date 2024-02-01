metadata description = 'Create API back-end application resources.'

param name string
param location string = resourceGroup().location
param tags object = {}
param serviceTag string

@description('Name of the Azure Container Apps environment.')
param envName string

@description('Endpoint for Azure Cosmos DB for NoSQL account.')
param databaseAccountEndpoint string

type managedIdentity = {
  resourceId: string
  clientId: string
}

@description('Unique identifier for user-assigned managed identity.')
param userAssignedManagedIdentity managedIdentity

resource environment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: envName
}

module app '../core/host/container-apps/app.bicep' = {
  name: 'container-apps-api-app'
  params: {
    name: name
    parentEnvironmentName: environment.name
    location: location
    tags: union(tags, {
        'azd-service-name': serviceTag
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
    externalAccess: true
    targetPort: 8080
    containerImage: 'mcr.microsoft.com/dotnet/samples:aspnetapp'
    enableSystemAssignedManagedIdentity: false
    userAssignedManagedIdentityIds: [
      userAssignedManagedIdentity.resourceId
    ]
  }
}

output endpoint string = app.outputs.endpoint
