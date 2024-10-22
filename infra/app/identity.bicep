metadata description = 'Create identity resources.'

param identityName string
param location string = resourceGroup().location
param tags object = {}

module userAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: 'user-assigned-identity'
  params: {
    name: identityName
    location: location
    tags: tags
  }
}

output resourceId string = userAssignedIdentity.outputs.resourceId
output principalId string = userAssignedIdentity.outputs.principalId
output clientId string = userAssignedIdentity.outputs.clientId
