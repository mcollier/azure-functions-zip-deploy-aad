@description('The Azure region for the specified resources.')
param location string = resourceGroup().location

@description('The name of the Function App to provision.')
param azureFunctionAppName string

@description('Specifies if the Azure Function app is accessible via HTTPS only.')
param httpsOnly bool = false

@description('The base name to be appended to all provisioned resources.')
@maxLength(13)
param resourceBaseName string = uniqueString(resourceGroup().id)

param applicationInsightsIntrumentationKey string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'st${resourceBaseName}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource azureFunctionPlan 'Microsoft.Web/serverfarms@2021-01-01' = {
  name: 'plan-${resourceBaseName}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource azureFunction 'Microsoft.Web/sites@2020-12-01' = {
  name: azureFunctionAppName
  location: location
  kind: 'functionapp'
  properties: {
    httpsOnly: httpsOnly
    serverFarmId: azureFunctionPlan.id

    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsIntrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
    }
  }

  resource config 'config' = {
    name: 'web'
    properties: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }

  resource publishingScmCredentialPolicies 'basicPublishingCredentialsPolicies' = {
    name: 'scm'
    location: location
    properties: {
      allow: false
    }
  }

  resource publishingFtpCredentialPolicies 'basicPublishingCredentialsPolicies' = {
    name: 'ftp'
    location: location
    properties: {
      allow: false
    }
  }
}

output azureFunctionAppName string = azureFunction.name
output azureFunctionId string = azureFunction.id
