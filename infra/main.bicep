targetScope = 'resourceGroup'

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
param logWorkspaceName string = ''
param cosmosDbAccountName string = ''
param containerRegistryName string = ''
param containerAppsEnvName string = ''
param containerAppsAppName string = ''

// serviceName is used as value for the tag (azd-service-name) azd uses to identify deployment host
param serviceName string = 'web'

var abbreviations = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(resourceGroup().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  repo: 'https://github.com/azure-samples/cosmos-db-nosql-dotnet-quickstart'
}

module identity 'app/identity.bicep' = {
  name: 'identity'
  params: {
    identityName: '${abbreviations.userAssignedIdentity}-${resourceToken}'
    location: location
    tags: tags
  }
}

module database 'app/database.bicep' = {
  name: 'database'
  params: {
    accountName: !empty(cosmosDbAccountName) ? cosmosDbAccountName : '${abbreviations.cosmosDbAccount}-${resourceToken}'
    location: location
    tags: tags
    appPrincipalId: identity.outputs.principalId
    userPrincipalId: !empty(principalId) ? principalId : null
  }
}

module registry 'app/registry.bicep' = {
  name: 'registry'
  params: {
    registryName: !empty(containerRegistryName) ? containerRegistryName : '${abbreviations.containerRegistry}${resourceToken}'
    location: location
    tags: tags
  }
}

module web 'app/web.bicep' = {
  name: serviceName
  params: {
    workspaceName: !empty(logWorkspaceName) ? logWorkspaceName : '${abbreviations.logAnalyticsWorkspace}-${resourceToken}'
    envName: !empty(containerAppsEnvName) ? containerAppsEnvName : '${abbreviations.containerAppsEnv}-${resourceToken}'
    appName: !empty(containerAppsAppName) ? containerAppsAppName : '${abbreviations.containerAppsApp}-${resourceToken}'
    location: location
    tags: tags
    serviceTag: serviceName    
    appResourceId: identity.outputs.resourceId
    appClientId: identity.outputs.clientId
    databaseAccountEndpoint: database.outputs.endpoint
  }
}

// Database outputs
output AZURE_COSMOS_DB_NOSQL_ENDPOINT string = database.outputs.endpoint

// Container outputs
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = registry.outputs.endpoint
output AZURE_CONTAINER_REGISTRY_NAME string = registry.outputs.name

// Application outputs
output AZURE_CONTAINER_APP_ENDPOINT string = web.outputs.endpoint
output AZURE_CONTAINER_ENVIRONMENT_NAME string = web.outputs.envName
