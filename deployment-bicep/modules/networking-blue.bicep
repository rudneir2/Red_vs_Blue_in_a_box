param parCompanyPrefix string = 'blue'

param parRegion string = resourceGroup().location

param parLogAnalyticsWorkspaceId string = ''

param parDDoSEnabled bool = false

param parDDoSPlanName string = '${parCompanyPrefix}-DDoS-Plan'

param parSpoketoHubRouteTableName string = '${parCompanyPrefix}-spoke-to-hub-routetable'

param parDNSServerIPArray array = []

param parHubNetworkAddressPrefix string = '10.0.25.0/24'

param parHubNetworkName string = '${parCompanyPrefix}-hub-vnet'

param parSpokeNetworkAddressPrefix string = '10.0.27.0/24'

param parSpokeNetworkName string = '${parCompanyPrefix}-spoke-vnet'

param parNetworkSecurityGroupSpokeName string = '${parSpokeNetworkName}-nsg'

param parNextHopIPAddress string = '10.0.25.4'

param parHubSubnets array = [
  {
    name: 'AGWAFSubnet'
    ipAddressRange: '10.0.25.64/26'
  }
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.0.25.0/26'
  }
]

param parSpokeSubnets array = [
  {
    name: 'Win10-subnet-1'
    ipAddressRange: '10.0.27.0/26'
  }
  {
    name: 'WinServer2019-subnet-2'
    ipAddressRange: '10.0.27.64/26'
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

resource resDDoSProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2021-02-01' = if (parDDoSEnabled) {
  name: parDDoSPlanName
  location: parRegion
}

resource resHubVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: parHubNetworkName
  location: parRegion
  properties: {
    addressSpace: {
      addressPrefixes: [
        parHubNetworkAddressPrefix
      ]
    }
    dhcpOptions: (!empty(parDNSServerIPArray) ? true : false) ? {
      dnsServers: parDNSServerIPArray
    } : null
    subnets: [for subnet in parHubSubnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.ipAddressRange
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        serviceEndpoints: empty(parServiceEndpoints) ? null : parServiceEndpoints        
      }
    }]
    enableDdosProtection: parDDoSEnabled
    ddosProtectionPlan: (parDDoSEnabled) ? {
      id: resDDoSProtectionPlan.id
    } : null
  }
}

resource resHubVirtualNetworkDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resHubVirtualNetwork
  name: 'DiagService'
  properties: {    
    workspaceId: empty(parLogAnalyticsWorkspaceId) ? null : parLogAnalyticsWorkspaceId
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
  }
}

resource resSpokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: parSpokeNetworkName
  location: parRegion
  properties: {
    addressSpace: {
      addressPrefixes: [
        parSpokeNetworkAddressPrefix
      ]
    }
    dhcpOptions: (!empty(parDNSServerIPArray) ? true : false) ? {
      dnsServers: parDNSServerIPArray
    } : null
    subnets: [for subnet in parSpokeSubnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.ipAddressRange
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        serviceEndpoints: empty(parServiceEndpoints) ? null : parServiceEndpoints        
        networkSecurityGroup: {
          id: resNetworkSecurityGroupSpoke.id
        }
        routeTable: {
          id: resSpoketoHubRT.id
        }
      }
    }]
    enableDdosProtection: parDDoSEnabled
    ddosProtectionPlan: (parDDoSEnabled) ? {
      id: resDDoSProtectionPlan.id
    } : null
  }
}

resource resSpokeVirtualNetworkDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resSpokeVirtualNetwork
  name: 'DiagService'
  properties: {    
    workspaceId: empty(parLogAnalyticsWorkspaceId) ? null : parLogAnalyticsWorkspaceId
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
  }
}

resource resPeeringHubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  parent: resHubVirtualNetwork
  name: '${resHubVirtualNetwork.name}-Peering-To-${resSpokeVirtualNetwork.name}'
  properties: {
    remoteVirtualNetwork: {
      id: resSpokeVirtualNetwork.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource resPeeringSpokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  parent: resSpokeVirtualNetwork
  name: '${resSpokeVirtualNetwork.name}-Peering-To-${resHubVirtualNetwork.name}'
  properties: {
    remoteVirtualNetwork: {
      id: resHubVirtualNetwork.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource resSpoketoHubRT 'Microsoft.Network/routeTables@2021-05-01' = {
  name: parSpoketoHubRouteTableName
  location: parRegion
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'DefaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: parNextHopIPAddress
        }
      }
    ]
  }
}

resource resNetworkSecurityGroupSpoke 'Microsoft.Network/networkSecurityGroups@2020-04-01' = {
  name: parNetworkSecurityGroupSpokeName
  location: parRegion
  tags: {}
  properties: {
    securityRules: [
      /*{
        name: 'Allow-Spoke2-VNET'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: VN_Name3Prefix
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
        name: 'Allow-Spoke2-VNET-outbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: VN_Name3Prefix
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }*/
    ]
  }
}

resource resNetworkSecurityGroupSpokeDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resNetworkSecurityGroupSpoke
  name: 'DiagService'
  properties: {    
    workspaceId: empty(parLogAnalyticsWorkspaceId) ? null : parLogAnalyticsWorkspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

output outDDoSPlanResourceID string = resDDoSProtectionPlan.id
output outHubVirtualNetworkName string = resHubVirtualNetwork.name
output outHubVirtualNetworkID string = resHubVirtualNetwork.id
output outSpokeVirtualNetworkName string = resSpokeVirtualNetwork.name
output outSpokeSubnetWin10VMName string = parSpokeSubnets[0].name
output outSpokeSubnetWinSrv2019VMName string = parSpokeSubnets[1].name
output outHubApplicationGatewaySubnetName string = parHubSubnets[0].name



