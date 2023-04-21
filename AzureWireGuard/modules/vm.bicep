param code string
param location string
param tags object
param vmSize string
param adminUsername string
@secure()
param adminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: 'vnet=wp-${code}'
}

resource snet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: 'snet-wg-${code}'
  parent: vnet
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: 'nsg-wg-${code}'
}

resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: 'pip-wg-${code}'
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'pip-wg-${code}'
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'nic-wg-${code}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-wg-${code}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: snet.id
          }
        }
      }
    ]
    enableAcceleratedNetworking: true
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'vm-wg-${code}'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'vmwg${code}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        name: 'osdisk-wg-${code}'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}

resource runCmd 'Microsoft.Compute/virtualMachines/runCommands@2022-11-01' = {
  name: 'run-wg-${code}'
  location: location
  tags: tags
  parent: vm
  properties: {
    asyncExecution: true
    source: {
      script: loadTextContent('../scripts/AzureWireGuard.sh')
    }
  }
}

output id string = vm.id
output name string = vm.name
output fqdn string = pip.properties.dnsSettings.fqdn
