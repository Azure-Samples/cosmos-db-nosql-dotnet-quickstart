metadata description = 'Create Azure Cosmos DB for NoSQL resources.'

param accountName string
param location string = resourceGroup().location
param tags object = {}

param database object = {
  name: 'cosmicworks' // Based on AdventureWorksLT data set
  autoscale: true // Scale at the database level
  throughput: 1000 // Enable autoscale with a minimum of 100 RUs and a maximum of 1,000 RUs
}

param containers array = [
  {
    name: 'products' // Set of products
    partitionKeyPaths: [
      '/category' // Partition on the product category
    ]
  }
]

module cosmosDbAccount '../core/database/cosmos-db/nosql/account.bicep' = {
  name: 'cosmos-db-account'
  params: {
    name: accountName
    location: location
    tags: tags
  }
}

module cosmosDbDatabase '../core/database/cosmos-db/nosql/database.bicep' = {
  name: 'cosmos-db-database'
  params: {
    name: database.name
    parentAccountName: cosmosDbAccount.outputs.name
    setThroughput: true
    autoscale: database.autoscale
    throughput: database.throughput
    tags: tags
  }
}

module cosmosDbContainers '../core/database/cosmos-db/nosql/container.bicep' = [for (container, index) in containers: {
  name: 'cosmos-db-container-${index}'
  params: {
    name: container.name
    parentAccountName: cosmosDbAccount.outputs.name
    parentDatabaseName: cosmosDbDatabase.outputs.name
    setThroughput: false
    partitionKeyPaths: container.partitionKeyPaths
    tags: tags
  }
}]

output endpoint string = cosmosDbAccount.outputs.endpoint
output accountName string = cosmosDbAccount.outputs.name
output database object = {
  name: cosmosDbDatabase.outputs.name
}
output containers array = [for (_, index) in containers: {
  name: cosmosDbContainers[index].outputs.name
}]
