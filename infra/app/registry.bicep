metadata description = 'Create container registries.'

param registryName string
param location string = resourceGroup().location
param tags object = {}

module containerRegistry '../core/host/container-registry/registry.bicep' = {
  name: 'container-registry'
  params: {
    name: registryName
    location: location
    tags: tags
    adminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccessEnabled: true
    skuName: 'Basic'
  }
}

output endpoint string = containerRegistry.outputs.endpoint
output name string = containerRegistry.outputs.name
