metadata description = 'Create database accounts.'

param accountName string
param location string = resourceGroup().location
param tags object = {}

@description('Id of the service principals to assign database and application roles.')
param appPrincipalId string

@description('Id of the user principals to assign database and application roles.')
param userPrincipalId string = ''

module cosmosDbAccount 'br/public:avm/res/document-db/database-account:0.6.1' = {
  name: 'cosmos-db-account'
  params: {
    name: accountName
    location: location
    tags: tags
    disableKeyBasedMetadataWriteAccess: true
    disableLocalAuth: true
    capabilitiesToAdd: [
      'EnableServerless'
    ]
    sqlRoleDefinitions: [
      {
        name: 'nosql-data-plane-contributor'
        dataAction: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata' // Read account metadata
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*' // Create items
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*' // Manage items      
        ]
      }
    ]
    sqlRoleAssignmentsPrincipalIds: union(
      [
        appPrincipalId
      ],
      !empty(userPrincipalId)
        ? [
            userPrincipalId
          ]
        : []
    )
    sqlDatabases: [
      {
        name: 'cosmicworks'
        containers: [
          {
            name: 'products'
            paths: [
              '/category'
            ]
          }
        ]
      }
    ]
  }
}

output endpoint string = cosmosDbAccount.outputs.endpoint
