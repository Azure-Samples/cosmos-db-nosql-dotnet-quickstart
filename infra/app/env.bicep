metadata description = 'Create cluster resources.'

param name string
param location string = resourceGroup().location
param tags object = {}

module containerAppsEnvironment '../core/host/container-apps/environments/managed.bicep' = {
  name: 'container-apps-env'
  params: {
    name: name
    location: location
    tags: tags
  }
}

output name string = containerAppsEnvironment.outputs.name
