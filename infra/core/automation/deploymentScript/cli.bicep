metadata description = 'Run Azure CLI deployment script.'

param name string
param location string = resourceGroup().location
param tags object = {}

@description('Environment variables to configure for the script.')
param envVariables array

@description('Script content to execute.')
param scriptContent string = 'az --version'

@description('The version of the Azure CLI to use. Defaults to latest.')
param version string = '2.49.0'

@description('Provides a user-assigned managed identity. This is unassigned by default.')
param userAssignedManagedIdentityId string = ''

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'AzureCLI'
  identity: !empty(userAssignedManagedIdentityId) ? {
    type: 'userAssigned'
    userAssignedIdentities: {
      userAssignedManagedIdentityId: {}
    }
  } : null
  properties: {
    azCliVersion: version
    scriptContent: scriptContent
    environmentVariables: envVariables
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
