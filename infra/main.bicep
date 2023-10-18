targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention.')
param environmentName string

@minLength(1)
@description('Primary location for all resources.')
param location string

@description('Id of the principal to assign database and application roles.')
param principalId string = ''

// Optional parameters
param cosmosDbAccountName string = ''
param containerRegistryName string = ''
param containerAppsEnvName string = ''
param containerAppsAppName string = ''
param userAssignedIdentityName string = ''

// serviceName is used as value for the tag (azd-service-name) azd uses to identify deployment host
param serviceName string = 'web'

var abbreviations = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  repo: 'https://github.com/azure-samples/cosmos-db-nosql-dotnet-quickstart'
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: environmentName
  location: location
  tags: tags
}

module identity 'app/identity.bicep' = {
  name: 'identity'
  scope: resourceGroup
  params: {
    identityName: !empty(userAssignedIdentityName) ? userAssignedIdentityName : '${abbreviations.userAssignedIdentity}-${resourceToken}'
    location: location
    tags: tags
  }
}

module account 'app/database.bicep' = {
  name: 'database'
  scope: resourceGroup
  params: {
    accountName: !empty(cosmosDbAccountName) ? cosmosDbAccountName : '${abbreviations.cosmosDbAccount}-${resourceToken}'
    location: location
    tags: tags
  }
}

module resources 'app/data.bicep' = {
  name: 'data'
  scope: resourceGroup
  params: {
    accountName: account.outputs.accountName
    tags: tags
  }
}

module container 'app/registry.bicep' = {
  name: 'registry'
  scope: resourceGroup
  params: {
    registryName: !empty(containerRegistryName) ? containerRegistryName : '${abbreviations.containerRegistry}${resourceToken}'
    location: location
    tags: tags
  }
}

module web 'app/web.bicep' = {
  name: serviceName
  scope: resourceGroup
  params: {
    envName: !empty(containerAppsEnvName) ? containerAppsEnvName : '${abbreviations.containerAppsEnv}-${resourceToken}'
    appName: !empty(containerAppsAppName) ? containerAppsAppName : '${abbreviations.containerAppsApp}-${resourceToken}'
    databaseAccountEndpoint: account.outputs.endpoint
    userAssignedManagedIdentityId: identity.outputs.identityId
    location: location
    tags: tags
    serviceTag: serviceName
  }
}

module security 'app/security.bicep' = {
  name: 'security'
  scope: resourceGroup
  params: {
    databaseAccountName: account.outputs.accountName
    principalIds: union([ identity.outputs.identityId ], empty(principalId) ? [] : [ principalId ])
  }
}

// Database outputs
output AZURE_COSMOS_ENDPOINT string = account.outputs.endpoint
output AZURE_COSMOS_DATABASE_NAME string = resources.outputs.database.name
output AZURE_COSMOS_CONTAINER_NAMES array = map(resources.outputs.containers, c => c.name)

// Container outputs
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = container.outputs.registryEndpoint
output AZURE_CONTAINER_REGISTRY_NAME string = container.outputs.registryName

// Application outputs
output AZURE_CONTAINER_APP_ENDPOINT string = web.outputs.endpoint
output AZURE_CONTAINER_ENVIRONMENT_NAME string = web.outputs.envName

// Identity outputs
output AZURE_USER_ASSIGNED_IDENTITY_ID string = identity.outputs.identityId

// Security outputs
output AZURE_NOSQL_ROLE_DEFINITION_ID string = security.outputs.nosqlRoleDefinitionId
