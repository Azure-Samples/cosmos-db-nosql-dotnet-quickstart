metadata description = 'Create Azure App Service resources.'

param planName string
param siteName string
param serviceTag string
param location string = resourceGroup().location
param tags object = {}

@description('Endpoint for Azure Cosmos DB for NoSQL account.')
param databaseAccountEndpoint string

module appServicePlan '../core/web/app-service/plan.bicep' = {
  name: 'app-service-plan'
  params: {
    name: planName
    location: location
    tags: tags
    kind: 'linux' // Use Linux
    sku: 'B1' // Basic tier
  }
}

module appServiceSite '../core/web/app-service/site.bicep' = {
  name: 'app-service-site'
  dependsOn: [
    appServicePlan
  ]
  params: {
    name: siteName
    parentPlanName: appServicePlan.outputs.name
    location: location
    tags: union(tags, {
        'azd-service-name': serviceTag
      })
    runtimeName: 'dotnetcore' // ASP.NET
    runtimeVersion: '7.0' // .NET 7 (LTS)
    enableSystemAssignedManagedIdentity: true // Create system-assigned managed identity
  }
}

module appServiceConfig '../core/web/app-service/config.bicep' = {
  name: 'app-service-config'
  dependsOn: [
    appServicePlan
    appServiceSite
  ]
  params: {
    parentSiteName: appServiceSite.outputs.name
    appSettings: {
      SCM_DO_BUILD_DURING_DEPLOYMENT: string(false)
      ENABLE_ORYX_BUILD: string(true)
      WEBSITES_PORT: '80'
      AZURE_COSMOS_DB_NOSQL_ENDPOINT: databaseAccountEndpoint
    }
  }
}

output endpoint string = appServiceSite.outputs.endpoint
output siteName string = appServiceSite.outputs.name
output siteManagedIdentityPrincipalId string = appServiceSite.outputs.managedIdentityPrincipalId
