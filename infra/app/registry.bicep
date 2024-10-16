metadata description = 'Create container registries.'

param registryName string
param location string = resourceGroup().location
param tags object = {}

module containerRegistry 'br/public:avm/res/container-registry/registry:0.5.1' = {
  name: 'container-registry'
  params: {
    name: registryName
    location: location
    tags: tags
    acrAdminUserEnabled: false
    anonymousPullEnabled: true
    publicNetworkAccess: 'Enabled'
    acrSku: 'Standard'
  }
}

output name string = containerRegistry.outputs.name
output resourceId string = containerRegistry.outputs.resourceId
output endpoint string = containerRegistry.outputs.loginServer
