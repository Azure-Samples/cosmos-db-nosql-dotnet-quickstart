metadata description = 'Runs deployment scripts to seed database data.'

param deploymentScriptName string
param location string = resourceGroup().location
param tags object = {}

param databaseAccountName string

resource database 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' existing = {
  name: databaseAccountName
}

module deploymentScript '../core/automation/deploymentScript/ps.bicep' = {
  name: 'ps-deployment-script'
  params: {
    name: deploymentScriptName
    location: location
    tags: tags
    scriptContent: '''
      apt-get update
      apt-get install -y dotnet-sdk-7.0
      dotnet tool install cosmicworks --tool-path ~/dotnet-tool --prerelease
      ~/dotnet-tool/cosmicworks --disable-formatting --hide-credentials --number-of-employees 0 --connection-string ${Env:COSMOS_DB_CONNECTION_STRING}
    '''
    envVariables: [
      {
        name: 'COSMOS_DB_CONNECTION_STRING'
        secureValue: database.listConnectionStrings().connectionStrings[0].connectionString
      }
    ]
  }
}
