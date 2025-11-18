# Infra Deployment (Azure App Service)

This folder contains a Bicep template to provision:
- Azure App Service Plan (Linux)
- Azure App Service (Web App) for a .NET 8 API
- Optional Application Insights (classic) and wiring of app settings

## Parameters
- `appName`: Global unique Web App name (required)
- `skuName`: Plan SKU (default: `B1`)
- `enableApplicationInsights`: Enable App Insights (default: `true`)
- `appInsightsLocation`: App Insights region (default: deployment location)
- `linuxFxVersion`: Runtime stack (default: `DOTNET|8.0`)
- `alwaysOn`: Keep app warm (default: `true`)
- `appSettings`: Additional app settings (object)
- `tags`: Tags for resources (object)

## Quick Start

1) Log in and set subscription
```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
```

2) Create a resource group (or use an existing one)
```bash
az group create -n <RG_NAME> -l <LOCATION>
```

3) Deploy the Bicep template
```bash
az deployment group create \
  --resource-group <RG_NAME> \
  --template-file infra/main.bicep \
  --parameters appName=<your-unique-app-name> \
               skuName=B1 \
               enableApplicationInsights=true
```

4) Show outputs
```bash
az deployment group show -g <RG_NAME> -n <deploymentName> --query properties.outputs
```

## Notes
- For .NET 8 on Linux, `linuxFxVersion` is typically `DOTNET|8.0`. In some regions, `DOTNETCORE|8.0` may be required.
- `APPINSIGHTS_INSTRUMENTATIONKEY` and `APPLICATIONINSIGHTS_CONNECTION_STRING` are auto-added to app settings when `enableApplicationInsights=true`.
- The Web App is created with `httpsOnly`, `FTPS disabled`, and `TLS 1.2+`.
- A system-assigned managed identity is enabled on the Web App.
