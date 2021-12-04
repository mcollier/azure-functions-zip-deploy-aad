targetScope = 'subscription'

param resourceGroupName string

var baseName = uniqueString(rg.id)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: deployment().location
}

module ai 'application-insights.bicep' = {
  scope: rg
  name: 'ai-deploy'
}

module func 'azure-function.bicep' = {
  scope: rg
  name: 'func-deploy'
  params: {
    azureFunctionAppName: 'app-${baseName}'
    applicationInsightsIntrumentationKey: ai.outputs.instrumentationKey
  }
}

output azureFunctionId string = func.outputs.azureFunctionId
