param parCompanyPrefix string = 'red'

param parRegion string = resourceGroup().location

param parAttackerNetworkAddressPrefix string = '10.0.28.0/24'
param parAttackerNetworkName string = '${parCompanyPrefix}-vnet'


param parAttackerNetworkSubnets array = [
  {
    name: 'KaliSubnet'
    ipAddressRange: '10.0.28.0/24'
  }
]

param parServiceEndpoints array = [
  {
    service: 'Microsoft.Web'
  }
  {
    service: 'Microsoft.Storage'
  }
  {
    service: 'Microsoft.Sql'
  }
  {
    service: 'Microsoft.ServiceBus'
  }
  {
    service: 'Microsoft.KeyVault'
  }
  {
    service: 'Microsoft.AzureActiveDirectory'
  }
]

resource resAttackerVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: parAttackerNetworkName
  location: parRegion
  properties: {
    addressSpace: {
      addressPrefixes: [
        parAttackerNetworkAddressPrefix
      ]
    }
    subnets: [for subnet in parAttackerNetworkSubnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.ipAddressRange
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        serviceEndpoints: empty(parServiceEndpoints) ? null : parServiceEndpoints        
      }
    }]
  }
}

output outAttackerVirtualNetworkName string = resAttackerVirtualNetwork.name
output outSpokeSubnetKaliVMName string = parAttackerNetworkSubnets[0].name
