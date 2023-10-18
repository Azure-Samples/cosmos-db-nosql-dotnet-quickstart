metadata description = 'Create database sub-resources.'

param accountName string
param tags object = {}

type database = {
  name: string
  autoscale: bool
  throughput: int
}

param rootDatabase database = {
  name: 'cosmicworks' // Based on AdventureWorksLT data set
  autoscale: true // Scale at the database level
  throughput: 1000 // Enable autoscale with a minimum of 100 RUs and a maximum of 1,000 RUs
}

type container = {
  name: string
  partitionKeyPaths: string[]
}

param containers container[] = [
  {
    name: 'products' // Set of products
    partitionKeyPaths: [
      '/category' // Partition on the product category
    ]
  }
]

module cosmosDbDatabase '../core/database/cosmos-db/nosql/database.bicep' = {
  name: 'cosmos-db-database-${rootDatabase.name}'
  params: {
    name: rootDatabase.name
    parentAccountName: accountName
    tags: tags
    setThroughput: true
    autoscale: rootDatabase.autoscale
    throughput: rootDatabase.throughput
  }
}

module cosmosDbContainers '../core/database/cosmos-db/nosql/container.bicep' = [for (container, _) in containers: {
  name: 'cosmos-db-container-${container.name}'
  params: {
    name: container.name
    parentAccountName: accountName
    parentDatabaseName: cosmosDbDatabase.outputs.name
    tags: tags
    setThroughput: false
    partitionKeyPaths: container.partitionKeyPaths
  }
}]

output database object = {
  name: cosmosDbDatabase.outputs.name
}
output containers array = [for (_, index) in containers: {
  name: cosmosDbContainers[index].outputs.name
}]
