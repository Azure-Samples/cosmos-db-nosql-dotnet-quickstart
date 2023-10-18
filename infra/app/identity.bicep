metadata description = 'Create identity resources.'

param identityName string
param location string = resourceGroup().location
param tags object = {}

module userAssignedIdentity '../core/security/identity/user-assigned.bicep' = {
  name: 'user-assigned-identity'
  params: {
    name: identityName
    location: location
    tags: tags
  }
}

output identityName string = userAssignedIdentity.outputs.name
output identityResourceId string = userAssignedIdentity.outputs.resourceId
output identityPrincipalId string = userAssignedIdentity.outputs.principalId
