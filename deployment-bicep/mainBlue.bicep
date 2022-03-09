targetScope = 'subscription'

param parBlueEnvironmentResourceGroupName string = 'blue-rg'

param parBlueEnvironmentLocation string = 'westeurope'

param parDDoSEnabled bool = false

param parBlueCompanyPrefix string = 'blue'

resource resBlueEnvironmentResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: parBlueEnvironmentLocation
  name: parBlueEnvironmentResourceGroupName
}

module modSentinel 'modules/sentinel.bicep' = {
  name: 'BlueSentinelDeployment'
  scope: resourceGroup(resBlueEnvironmentResourceGroup.name)
  params: {
    parLogAnalyticsWorkspaceRegion: parBlueEnvironmentLocation
    parCompanyPrefix: parBlueCompanyPrefix
  }
}

module modNetworkingBlue 'modules/networking-blue.bicep' = {
  name: 'BlueNetworkingDeployment'
  scope: resourceGroup(resBlueEnvironmentResourceGroup.name)
  params: {
    parLogAnalyticsWorkspaceId: modSentinel.outputs.outLogAnalyticsWorkspaceId
    parDDoSEnabled: parDDoSEnabled
    parRegion: parBlueEnvironmentLocation
    parCompanyPrefix: parBlueCompanyPrefix
  }
}

module modVMsBlue 'modules/vms-blue.bicep' = {
  name: 'BlueVmsDeployment'
  scope: resourceGroup(resBlueEnvironmentResourceGroup.name)
  params: {
    parRegion: parBlueEnvironmentLocation
    parSpokeNetworkName: modNetworkingBlue.outputs.outSpokeVirtualNetworkName
    parWin10SubnetName: modNetworkingBlue.outputs.outSpokeSubnetWin10VMName
    parWinSrv2019SubnetName: modNetworkingBlue.outputs.outSpokeSubnetWinSrv2019VMName
  }
}

module modWebApp 'modules/webapp.bicep' = {
  name: 'BlueWebAppDeployment'
  scope: resourceGroup(resBlueEnvironmentResourceGroup.name)
  params:{
    parRegion: parBlueEnvironmentLocation
    parCompanyPrefix: parBlueCompanyPrefix
    parLogAnalyticsWorkspaceId: modSentinel.outputs.outLogAnalyticsWorkspaceId
  }
}

module modNetworkSecurityBlue 'modules/networksecurity-blue.bicep' = {
  name: 'BlueNetworkSecurityDeployment'
  scope: resourceGroup(resBlueEnvironmentResourceGroup.name)
  params: {
    parRegion: parBlueEnvironmentLocation
    parLogAnalyticsWorkspaceId: modSentinel.outputs.outLogAnalyticsWorkspaceId
    parApplicationGatewaySubnetName: modNetworkingBlue.outputs.outHubApplicationGatewaySubnetName
    parHubNetworkName: modNetworkingBlue.outputs.outHubVirtualNetworkName
    parCompanyPrefix: parBlueCompanyPrefix
    parWin10IPAddress: modVMsBlue.outputs.outWin10IPAddress
    parWinServer2019IPAddress: modVMsBlue.outputs.outWinSrv2019IPAddress
    parWebAppName: modWebApp.outputs.outWebSiteName
  }
}



