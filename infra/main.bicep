// Azure App Service (Linux) + Plan + optional Application Insights

@description('Name of the Web App (must be globally unique).')
param appName string

@description('App Service Plan SKU (e.g., B1, S1, P1v3).')
param skuName string = 'B1'

@description('Enable Application Insights.')
param enableApplicationInsights bool = true

@description('Location for Application Insights.')
param appInsightsLocation string = resourceGroup().location

@description('Optional deployment slot name. Leave empty to skip slot creation.')
param slotName string = ''

var planName = '${appName}-plan'
var location = resourceGroup().location

// App Service Plan (Linux)
resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planName
  location: location
  sku: {
    name: skuName
  }
  kind: 'linux'
  properties: {
    reserved: true // Linux
  }
}

// Web App (Linux)
resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNET|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

// Optional deployment slot
resource slot 'Microsoft.Web/sites/slots@2022-09-01' = if (slotName != '') {
  name: '${app.name}/${slotName}'
  location: location
  kind: 'app,linux'
  properties: {
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNET|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

// Optional Application Insights
resource appInsights 'microsoft.insights/components@2020-02-02' = if (enableApplicationInsights) {
  name: '${appName}-ai'
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
  }
}

// App settings with Application Insights (if enabled)
var appSettingsConfig = enableApplicationInsights ? {
  ASPNETCORE_ENVIRONMENT: 'Production'
  APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
  APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
} : {
  ASPNETCORE_ENVIRONMENT: 'Production'
}

// Apply app settings to production slot
resource appSettingsRes 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: app
  properties: appSettingsConfig
}

// Apply app settings to deployment slot (if exists)
resource slotAppSettings 'Microsoft.Web/sites/slots/config@2022-09-01' = if (slotName != '') {
  name: 'appsettings'
  parent: slot
  properties: appSettingsConfig
}

// Outputs
output webAppName string = app.name
output webAppHostname string = 'https://${app.properties.defaultHostName}'
output appServicePlanId string = plan.id
output appInsightsConnectionString string = enableApplicationInsights ? appInsights.properties.ConnectionString : ''
output slotHostname string = slotName != '' ? 'https://${slot.properties.hostNames[0]}' : ''
