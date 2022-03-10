param parCompanyPrefix string = 'blue'
param parLogAnalyticsWorkspaceName string = '${parCompanyPrefix}-log-analytics'
param parLogAnalyticsWorkspaceRegion string = resourceGroup().location
param parLogAnalyticsWorkspaceLogRetentionInDays int = 30

@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param parLogAnalyticsWorkspaceSku string = 'PerGB2018'

@allowed([
  'AgentHealthAssessment'
  'AntiMalware'
  'AzureActivity'
  'ChangeTracking'
  'Security'
  'SecurityInsights'
  'ServiceMap'
  'SQLAssessment'
  'Updates'
  'VMInsights'
])
@description('Solutions that will be added to the Log Analytics Workspace.')
param parLogAnalyticsWorkspaceSolutions array = [
  'AgentHealthAssessment'
  'AntiMalware'
  'Security'
  'SecurityInsights'
]

resource resLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: parLogAnalyticsWorkspaceName
  location: parLogAnalyticsWorkspaceRegion
  properties: {
    sku: {
      name: parLogAnalyticsWorkspaceSku
    }
    retentionInDays: parLogAnalyticsWorkspaceLogRetentionInDays
  }
}

resource resLogAnalyticsWorkspaceSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in parLogAnalyticsWorkspaceSolutions: {
  name: '${solution}(${resLogAnalyticsWorkspace.name})'
  location: parLogAnalyticsWorkspaceRegion
  properties: {
    workspaceResourceId: resLogAnalyticsWorkspace.id
  }
  plan: {
    name: '${solution}(${resLogAnalyticsWorkspace.name})'
    product: 'OMSGallery/${solution}'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}]

output outLogAnalyticsWorkspaceName string = resLogAnalyticsWorkspace.name
output outLogAnalyticsWorkspaceId string = resLogAnalyticsWorkspace.id
output outLogAnalyticsSolutions array = parLogAnalyticsWorkspaceSolutions
