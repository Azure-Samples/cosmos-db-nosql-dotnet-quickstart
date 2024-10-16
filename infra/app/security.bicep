metadata description = 'Create role assignment for web application.'

@description('Resource Id of the container registry.')
param containerRegistryResourceId string

@description('Id of the user principals to assign database and application roles.')
param userPrincipalId string = ''

module registryUserAssignment 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (!empty(userPrincipalId)) {
  name: 'container-registry-role-assignment-push-user'
  params: {
    principalId: userPrincipalId
    resourceId: containerRegistryResourceId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '8311e382-0749-4cb8-b61a-304f252e45ec' // AcrPush built-in role
    )
  }
}
