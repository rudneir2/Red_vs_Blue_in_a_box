param parRegion string = resourceGroup().location

param parWin10VmName string = 'VM-Win10'

param parWin10VmSku string = 'Standard_B2s'

param parWin10VmIPAddress string = '10.0.27.4'

param parWinSrv2019VmName string = 'VM-Win2019'

param parWinSrv2019VmSku string = 'Standard_B2s'

param parWinSrv2019VmIPAddress string = '10.0.27.68'

param parSpokeNetworkName string

param parWin10SubnetName string

param parWinSrv2019SubnetName string

param parDefaultUserName string = 'svradmin'

@description('Password for the Builtin Administrator account. Default is \'H@ppytimes!\'')
@secure()
param parDefaultPassword string = 'H@ppytimes123!'


resource resSpokeNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {  
  name: parSpokeNetworkName
}

resource resWin10SubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent:  resSpokeNetwork
  name: parWin10SubnetName
}

resource resWinSrv2019SubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent:  resSpokeNetwork
  name: parWinSrv2019SubnetName
}

resource resNicWin10Vm 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${parWin10VmName}-nic'
  location: parRegion
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: parWin10VmIPAddress
          subnet: {
            id: resWin10SubnetRef.id
          }
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
  }
}

resource parWin10Vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: parWin10VmName
  location: parRegion
  properties: {
    hardwareProfile: {
      vmSize: parWin10VmSku
    }
    storageProfile: {
      osDisk: {
        name: '${parWin10VmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '20h2-pro'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resNicWin10Vm.id
        }
      ]
    }
    osProfile: {
      computerName: parWin10VmName
      adminUsername: parDefaultUserName
      adminPassword: parDefaultPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
}

resource resNicWinSrv2019Vm 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${parWinSrv2019VmName}-nic'
  location: parRegion
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: parWinSrv2019VmIPAddress
          subnet: {
            id: resWinSrv2019SubnetRef.id
          }
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
  }
}

resource resWinSrv2019Vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: parWinSrv2019VmName
  location: parRegion
  properties: {
    hardwareProfile: {
      vmSize: parWinSrv2019VmSku
    }
    storageProfile: {
      osDisk: {
        name: '${parWinSrv2019VmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resNicWinSrv2019Vm.id
        }
      ]
    }
    osProfile: {
      computerName: parWinSrv2019VmName
      adminUsername: parDefaultUserName
      adminPassword: parDefaultPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    licenseType: 'Windows_Server'
  }
}

output outWin10IPAddress string = resNicWin10Vm.properties.ipConfigurations[0].properties.privateIPAddress
output outWinSrv2019IPAddress string = resNicWinSrv2019Vm.properties.ipConfigurations[0].properties.privateIPAddress
