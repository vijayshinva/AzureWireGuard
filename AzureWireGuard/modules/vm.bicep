param code string
param location string
param tags object
param vmSize string
param adminUsername string
@secure()
param adminPassword string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: 'vnet-wg-${code}'
}

resource snet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: 'snet-wg-${code}'
  parent: virtualNetwork
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: 'nsg-wg-${code}'
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
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

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-07-01' = {
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
          publicIPAddress: {
            id: publicIPAddress.id
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

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' = {
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
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: 'osdisk-wg-${code}'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 64
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
          id: networkInterface.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource runCmd 'Microsoft.Compute/virtualMachines/runCommands@2022-11-01' = {
  name: 'run-wg-${code}'
  location: location
  tags: tags
  parent: virtualMachine
  properties: {
    asyncExecution: false
    parameters: [
      {
        name: ''
        value: publicIPAddress.properties.dnsSettings.fqdn
      }
      {
        name: ''
        value: adminUsername
      }
    ]
    runAsUser: 'root'
    source: {
      script: loadTextContent('../scripts/AzureWireGuard.sh')
    }
  }
}

output id string = virtualMachine.id
output name string = virtualMachine.name
output fqdn string = publicIPAddress.properties.dnsSettings.fqdn
