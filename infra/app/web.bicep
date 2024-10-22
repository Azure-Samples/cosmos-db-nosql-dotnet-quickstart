metadata description = 'Create web application resources.'

param planName string
param appName string
param serviceTag string
param location string = resourceGroup().location
param tags object = {}

@description('Endpoint for Azure Cosmos DB for Table account.')
param databaseAccountEndpoint string

@description('Client ID of the service principal to assign database and application roles.')
param appClientId string

@description('Resource ID of the service principal to assign database and application roles.')
param appResourceId string

module appServicePlan 'br/public:avm/res/web/serverfarm:0.3.0' = {
  name: 'app-service-plan'
  params: {
    name: planName
    location: location
    tags: tags
    skuCapacity: 1
    skuName: 'F1'
    kind: 'Linux'
    zoneRedundant: false
  }
}

module appServiceWebApp 'br/public:avm/res/web/site:0.9.0' = {
  name: 'app-service-web-app'
  params: {
    name: appName
    location: location
    tags: union(tags, { 'azd-service-name': serviceTag })
    kind: 'app,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    managedIdentities: {
      systemAssigned: false
      userAssignedResourceIds: [
        appResourceId
      ]
    }
    siteConfig: {
      appSettings: [
        {
          name: 'AZURE_COSMOS_DB_NOSQL_ENDPOINT'
          value: databaseAccountEndpoint
        }
        {
          name: 'AZURE_CLIENT_ID'
          value: appClientId
        }
      ]
      linuxFxVersion: 'DOTNETCORE:9.0'
    }
  }
}
