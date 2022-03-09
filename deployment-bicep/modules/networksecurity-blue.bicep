param parCompanyPrefix string = 'blue'

param parRegion string = resourceGroup().location

param parLogAnalyticsWorkspaceId string = ''

param parHubNetworkName string = '${parCompanyPrefix}-hub-vnet'

@allowed([
  'Standard'
  'Premium'
])
param parAzureFirewallTier string = 'Standard'

param parAzureFirewallName string = '${parCompanyPrefix}-azure-firewall'

param parApplicationGatewayName string = '${parCompanyPrefix}-application-gateway'

param parApplicationGatewaySubnetName string

param parApplicationGatewayPrivateIP string  = '10.0.25.70'

param parAppGatewayWAFPolicyName string = '${parCompanyPrefix}-WAF-policy'

param parWebAppName string

param parWin10IPAddress string

param parWinServer2019IPAddress string

resource resHubVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: parHubNetworkName
}

resource resAzureFirewallSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: resHubVirtualNetwork
  name: 'AzureFirewallSubnet'
}

resource resAzureFirewallPublicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' ={
  name: '${parAzureFirewallName}-PublicIP'
  location: parRegion
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource resAzureFirewallPublicIPDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resAzureFirewallPublicIP
  name: 'DiagService'
  properties: {    
    workspaceId: empty(parLogAnalyticsWorkspaceId) ? null : parLogAnalyticsWorkspaceId
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
      }
      {
        category: 'DDoSMitigationReports'
        enabled: true
      }
    ]
  }
}

resource resAzureFirewall 'Microsoft.Network/azureFirewalls@2021-02-01' = {
  name: parAzureFirewallName
  location: parRegion
  properties: {
    firewallPolicy: {
      id: resFirewallPolicy.id
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resAzureFirewallSubnetRef.id
          }
          publicIPAddress: {
            id: resAzureFirewallPublicIP.id
          }
        }
      }
    ]
    threatIntelMode: 'Deny'
    sku: {
      name: 'AZFW_VNet'
      tier: parAzureFirewallTier
    }
  }
}

resource resAzureFirewallDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resAzureFirewall
  name: 'DiagService'
  properties: {    
    workspaceId: empty(parLogAnalyticsWorkspaceId) ? null : parLogAnalyticsWorkspaceId
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
        retentionPolicy: {
          days: 10
          enabled: false
        }
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
        retentionPolicy: {
          days: 10
          enabled: false
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

resource resFirewallPolicy 'Microsoft.Network/firewallPolicies@2019-06-01' = {
  name: '${parAzureFirewallName}-policy'
  location: parRegion
  properties: {
    threatIntelMode: 'Deny'
  }
  dependsOn: []
}

resource resFirewallPolicy_DefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleGroups@2019-06-01' = {
  parent: resFirewallPolicy
  name: 'DefaultDnatRuleCollectionGroup'
  //location: parRegion
  properties: {
    priority: 100
    rules: [
      {
        name: 'APPGW-WEBAPP'
        priority: 100
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'DNAT'
        }
        ruleCondition: {
          name: 'DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '443'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            resAzureFirewallPublicIP.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: resAppGWPublicIP.properties.ipAddress
        translatedPort: '443'
      }
      {
        name: 'Win10'
        priority: 101
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'DNAT'
        }
        ruleCondition: {
          name: 'DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '33891'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            resAzureFirewallPublicIP.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: parWin10IPAddress
        translatedPort: '3389'
      }
      /*{
        name: 'Kali-SSH'
        priority: 102
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'DNAT'
        }
        ruleCondition: {
          name: 'SSH-DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '22'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            resAzureFirewallPublicIP.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: NIC_Name2Ipaddress
        translatedPort: '22'
      }
      {
        name: 'Kali-RDP'
        priority: 103
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'DNAT'
        }
        ruleCondition: {
          name: 'DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '33892'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            resAzureFirewallPublicIP.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: NIC_Name2Ipaddress
        translatedPort: '3389'
      }*/
      {
        name: 'WinServer2019'
        priority: 104
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'DNAT'
        }
        ruleCondition: {
          name: 'DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '33890'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            resAzureFirewallPublicIP.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: parWinServer2019IPAddress
        translatedPort: '3389'
      }
    ]
  }
}

resource resFirewallPolicy_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleGroups@2019-06-01' = {
  parent: resFirewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  //location: parRegion
  properties: {
    priority: 200
    rules: [
      {
        name: 'IntraVNETandHTTPOutAccess'
        priority: 100
        ruleType: 'FirewallPolicyFilterRule'
        action: {
          type: 'Allow'
        }
        ruleConditions: [
          {
            name: 'SMB'
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '445'
            ]
            sourceAddresses: [
              parWin10IPAddress
              parWinServer2019IPAddress
            ]
            destinationAddresses: [
              parWin10IPAddress
              parWinServer2019IPAddress
            ]
            ruleConditionType: 'NetworkRuleCondition'
          }
          {
            name: 'RDP'
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '3389'
            ]
            sourceAddresses: [
              parWin10IPAddress
              parWinServer2019IPAddress
            ]
            destinationAddresses: [
              parWin10IPAddress
              parWinServer2019IPAddress
            ]
            ruleConditionType: 'NetworkRuleCondition'
          }
          {
            name: 'SSH'
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '22'
            ]
            sourceAddresses: [
              parWinServer2019IPAddress
              /* Kali? */
            ]
            destinationAddresses: [
              parWin10IPAddress
            ]
            ruleConditionType: 'NetworkRuleCondition'
          }
          /*{
            name: 'Kali-HTTP'
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '80'
            ]
            sourceAddresses: [
              Kali?
            ]
            destinationAddresses: [
              '*'
            ]
            ruleConditionType: 'NetworkRuleCondition'
          }*/
        ]
      }
    ]
  }
}

resource resFirewallPolicy_DefaultApplicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleGroups@2019-06-01' = {
  parent: resFirewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  //location: parRegion
  properties: {
    priority: 300
    rules: [
      {
        name: 'Internet-Access'
        priority: 100
        ruleType: 'FirewallPolicyFilterRule'
        action: {
          type: 'Allow'
        }
        ruleConditions: [
          {
            name: 'SearchEngineAccess'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: [
              '*'
            ]
            targetFqdns: [
              'www.google.com'
              'www.bing.com'
              'google.com'
              'bing.com'
            ]
            fqdnTags: []
            ruleConditionType: 'ApplicationRuleCondition'
          }
          /*{
            name: 'Kali-InternetAccess'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: [
              NIC_Name2Ipaddress
            ]
            targetFqdns: [
              '*'
            ]
            fqdnTags: []
            ruleConditionType: 'ApplicationRuleCondition'
          }*/
        ]
      }
    ]
  }
}


resource resAppGWPublicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' ={
  name: '${parAzureFirewallName}-PublicIP'
  location: parRegion
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource resAppGWPublicIPDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resAppGWPublicIP
  name: 'DiagService'
  properties: {    
    workspaceId: empty(parLogAnalyticsWorkspaceId) ? null : parLogAnalyticsWorkspaceId
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
      }
      {
        category: 'DDoSMitigationReports'
        enabled: true
      }
    ]
  }
}

resource resApplicationGatewaySubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: resHubVirtualNetwork
  name: parApplicationGatewaySubnetName
}

resource resApplicationGateway 'Microsoft.Network/applicationGateways@2021-05-01' = {
  name: parApplicationGatewayName
  location: parRegion
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resApplicationGatewaySubnetRef.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: resAppGWPublicIP.id
          }
        }
      }
      {
        name: 'appGwPrivateFrontendIp'
        properties: {
          subnet: {
            id: resApplicationGatewaySubnetRef.id
          }
          privateIPAddress: parApplicationGatewayPrivateIP
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_8080'
        properties: {
          port: 8080
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'PAAS-APP'
        properties: {
          backendAddresses: [
            {
              fqdn: '${parWebAppName}.azurewebsites.net'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'Default'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: '${parWebAppName}.azurewebsites.net'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'Public-HTTP'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', parApplicationGatewayName,'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', parApplicationGatewayName,'port_80')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'PublicIPRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', parApplicationGatewayName,'Public-HTTP')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', parApplicationGatewayName,'PAAS-APP')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', parApplicationGatewayName,'Default')
          }
        }
      }
    ]
    enableHttp2: false
    firewallPolicy: {
      id: resAppGatewayWAFPolicy.id
    }
  }
}

resource resApplicationGatewayDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resApplicationGateway
  name: 'DiagService'
  properties: {    
    workspaceId: empty(parLogAnalyticsWorkspaceId) ? null : parLogAnalyticsWorkspaceId
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
  }
}

resource resAppGatewayWAFPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-05-01' = {
  name: parAppGatewayWAFPolicyName
  location: parRegion
  tags: {}
  properties: {
    customRules: [
      {
        name: 'SentinelBlockIP'
        priority: 10
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: false
            matchValues: [
              '104.210.223.108'
            ]
            transforms: []
          }
        ]
      }
      {
        name: 'BlockGeoLocationChina'
        priority: 20
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'GeoMatch'
            negationConditon: false
            matchValues: [
              'CN'
            ]
            transforms: []
          }
        ]
      }
      {
        name: 'BlockInternetExplorer11'
        priority: 30
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RequestHeaders'
                selector: 'User-Agent'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'rv:11.0'
            ]
            transforms: []
          }
        ]
      }
    ]
    policySettings: {
      fileUploadLimitInMb: 100
      maxRequestBodySizeInKb: 128
      mode: 'Prevention'
      requestBodyCheck: true
      state: 'Enabled'
    }
    managedRules: {
      exclusions: []
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920350'
                  state: 'Disabled'
                }
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
              ]
            }
          ]
        }
      ]
    }
  }
}

