targetScope = 'subscription'

param parRedEnvironmentResourceGroupName string = 'red-rg'

param parRedEnvironmentLocation string = 'westeurope'

param parRedCompanyPrefix string = 'red'

resource resRedEnvironmentResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: parRedEnvironmentLocation
  name: parRedEnvironmentResourceGroupName
}

module modNetworkingRed 'modules/networking-red.bicep' = {
  name: 'RedNetworkingDeployment'
  scope: resourceGroup(resRedEnvironmentResourceGroup.name)
  params: {
    parRegion: parRedEnvironmentLocation
    parCompanyPrefix: parRedCompanyPrefix
  }
}

module modVMsRed 'modules/vms-red.bicep' = {
  name: 'RedVmsDeployment'
  scope: resourceGroup(resRedEnvironmentResourceGroup.name)
  params: {
    parRegion: parRedEnvironmentLocation
    parAttackerNetworkName: modNetworkingRed.outputs.outAttackerVirtualNetworkName
    parKaliVMSubnetName: modNetworkingRed.outputs.outSpokeSubnetKaliVMName
  }
}
