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

param parNetworkSecurityGroupKaliSubnetName string = '${parAttackerNetworkName}-kali-nsg'

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
        networkSecurityGroup: {
          id: resNetworkSecurityGroupKali.id
        }
      }
    }]
  }
}

resource resNetworkSecurityGroupKali 'Microsoft.Network/networkSecurityGroups@2020-04-01' = {
  name: parNetworkSecurityGroupKaliSubnetName
  location: parRegion
  tags: {}
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow-RDP'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

output outAttackerVirtualNetworkName string = resAttackerVirtualNetwork.name
output outSpokeSubnetKaliVMName string = parAttackerNetworkSubnets[0].name
