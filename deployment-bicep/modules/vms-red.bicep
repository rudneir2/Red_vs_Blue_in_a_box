param parRegion string = resourceGroup().location

param parKaliVmName string = 'VM-Kali'

param parKaliVmSku string = 'Standard_B2s'

param parKaliVmIPAddress string = '10.0.28.4'

param parAttackerNetworkName string

param parKaliVMSubnetName string

param parDefaultUserName string = 'svradmin'

@description('Password for the Builtin Administrator account. Default is \'H@ppytimes!\'')
@secure()
param parDefaultPassword string = 'H@ppytimes123!'

resource resAttackerNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {  
  name: parAttackerNetworkName
}

resource resKaliVmSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent:  resAttackerNetwork
  name: parKaliVMSubnetName
}

resource resKaliVMPublicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' ={
  name: '${parKaliVmName}-PublicIP'
  location: parRegion
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource resNicKaliVm 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${parKaliVmName}-nic'
  location: parRegion
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: parKaliVmIPAddress
          subnet: {
            id: resKaliVmSubnetRef.id
          }
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: resKaliVMPublicIP.id
          }
        }
      }
    ]
  }
}

resource resKaliVm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: parKaliVmName
  location: parRegion
  plan: {
    name: 'kali'
    publisher: 'kali-linux'
    product: 'kali-linux'
  }
  properties: {
    hardwareProfile: {
      vmSize: parKaliVmSku
    }
    storageProfile: {
      osDisk: {
        name: '${parKaliVmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'kali-linux'
        offer: 'kali-linux'
        sku: 'kali'
        version: '2019.2.0'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resNicKaliVm.id
        }
      ]
    }
    osProfile: {
      computerName: parKaliVmName
      adminUsername: parDefaultUserName
      adminPassword: parDefaultPassword
    }
  }
}

output outKaliLinuxPublicIP string = resKaliVMPublicIP.properties.ipAddress

