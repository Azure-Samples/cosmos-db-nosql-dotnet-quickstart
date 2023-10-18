metadata description = 'Creates a Microsoft Entra user-assigned identity.'

param name string
param location string = resourceGroup().location
param tags object = {}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

output name string = identity.name
output id string = identity.id
