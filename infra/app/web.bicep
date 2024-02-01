metadata description = 'Create web front-end application resources.'

param name string
param location string = resourceGroup().location
param tags object = {}
param serviceTag string

@description('Name of the Azure Container Apps environment.')
param envName string

@description('The endpoint of the API app to connect to.')
param apiAppEndpoint string

resource environment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: envName
}

module app '../core/host/container-apps/app.bicep' = {
  name: 'container-apps-web-app'
  params: {
    name: name
    parentEnvironmentName: environment.name
    location: location
    tags: union(tags, {
        'azd-service-name': serviceTag
      })
    secrets: [
      {
        name: 'base-api-url' // Create a uniquely-named secret
        value: apiAppEndpoint // Endpoint to API app
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
    targetPort: 8080
    containerImage: 'mcr.microsoft.com/dotnet/samples:aspnetapp'
  }
}

output endpoint string = app.outputs.endpoint
