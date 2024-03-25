param code string
param location string
param tags object

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'nsg-wg-${code}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-WireGuard-Inbound'
        properties: {
          description: 'Allow Wireguard 51820'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '51820'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 1001
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-SSH-Inbound'
        properties: {
          description: 'Allow SSH 22'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 1002
          direction: 'Inbound'
        }
      }
    ]
  }
  tags: tags
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-wg-${code}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.13.13.0/24'
      ]
    }
    subnets: [
      {
        name: 'snet-wg-${code}'
        properties: {
          addressPrefix: '10.13.13.0/25'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

output id string = vnet.id
output name string = vnet.name
