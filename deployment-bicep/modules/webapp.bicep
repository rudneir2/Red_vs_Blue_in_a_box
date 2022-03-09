param parCompanyPrefix string = 'blue'

param parWebSiteName string = '${parCompanyPrefix}-web-app'

param parAppServicePlanName string = '${parWebSiteName}-app-service-plan'

param parRegion string = resourceGroup().location

param parLogAnalyticsWorkspaceId string = ''

param parAppServicePlanSku string = 'P1v2'

resource resWebSite 'Microsoft.Web/sites@2021-03-01' = {
  name: parWebSiteName
  location: parRegion
  tags: {}
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://index.docker.io'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      linuxFxVersion: 'DOCKER|mohitkusecurity/juice-shop-updated'
      alwaysOn: true
    }
    serverFarmId: resAppServicePlan.id
    clientAffinityEnabled: false
  }
}

resource resAppServicePlan 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: parAppServicePlanName
  location: parRegion
  sku: {
    name: parAppServicePlanSku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource resWebSiteDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resWebSite
  name: 'DiagService'
  properties: {    
    workspaceId: empty(parLogAnalyticsWorkspaceId) ? null : parLogAnalyticsWorkspaceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: true
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 3
        }
      }
    ]
  }
}

output outWebSiteName string = resWebSite.name
