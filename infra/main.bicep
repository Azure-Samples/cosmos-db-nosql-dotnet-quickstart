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
param appServicePlanName string = ''
param appServiceSiteName string = ''

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

module database 'app/database.bicep' = {
  name: 'database'
  scope: resourceGroup
  params: {
    accountName: !empty(cosmosDbAccountName) ? cosmosDbAccountName : '${abbreviations.cosmosDbAccount}-${resourceToken}'
    location: location
    tags: tags
  }
}

module web 'app/web.bicep' = {
  name: serviceName
  scope: resourceGroup
  params: {
    planName: !empty(appServicePlanName) ? appServicePlanName : '${abbreviations.appServicePlan}-${resourceToken}'
    siteName: !empty(appServiceSiteName) ? appServiceSiteName : '${abbreviations.appServiceSite}-${resourceToken}'
    databaseAccountEndpoint: database.outputs.endpoint
    location: location
    tags: tags
    serviceTag: serviceName
  }
}

module security 'app/security.bicep' = {
  name: 'security'
  scope: resourceGroup
  params: {
    databaseAccountName: database.outputs.accountName
    principalIds: empty(principalId) ? [ web.outputs.siteManagedIdentityPrincipalId ] : [ principalId, web.outputs.siteManagedIdentityPrincipalId ]
  }
}

// Database outputs
output AZURE_COSMOS_ENDPOINT string = database.outputs.endpoint
output AZURE_COSMOS_DATABASE_NAME string = database.outputs.database.name
output AZURE_COSMOS_CONTAINER_NAMES array = map(database.outputs.containers, c => c.name)

// Application outputs
output AZURE_CONTAINER_APP_ENDPOINT string = web.outputs.endpoint

// Security outputs
output AZURE_NOSQL_ROLE_DEFINITION_ID string = security.outputs.nosqlRoleDefinitionId
