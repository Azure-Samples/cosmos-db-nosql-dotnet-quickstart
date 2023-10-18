metadata description = 'Create role assignment and definition resources.'

param databaseAccountName string

type principal = {
  name: string
  principalId: string
}

@description('Id of the principal to assign database and application roles.')
param principals principal[]

resource database 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: databaseAccountName
}

module nosqlDefinition '../core/database/cosmos-db/nosql/role/definition.bicep' = {
  name: 'nosql-role-definition'
  params: {
    targetAccountName: database.name // Existing account
    definitionName: 'Write to Azure Cosmos DB for NoSQL data plane' // Custom role name
    permissionsDataActions: [
      'Microsoft.DocumentDB/databaseAccounts/readMetadata' // Read account metadata
      'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*' // Create items
      'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*' // Manage items
    ]
  }
}

module nosqlAssignments '../core/database/cosmos-db/nosql/role/assignment.bicep' = [for (principal, _) in principals: {
  name: 'nosql-role-assignment-${principal.name}'
  params: {
    targetAccountName: database.name // Existing account
    roleDefinitionId: nosqlDefinition.outputs.id // New role definition
    principalId: principal.principalId // Principal to assign role
  }
}]

output nosqlRoleDefinitionId string = nosqlDefinition.outputs.id
output nosqlRoleAssignmentIds array = [for (_, index) in principals: nosqlAssignments[index].outputs.id]

