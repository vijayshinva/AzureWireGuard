param location string = 'eastus'
param code string = uniqueString(subscription().id, location)
param tags object = {}
param vmSize string = 'Standard_DS2_v2'
@maxLength(16)
param adminUsername string = 'vmadmin'
@secure()
param adminPassword string
param timeStamp string = utcNow('u')

targetScope = 'subscription'

var xtags = union(tags, {
    DeployedOn: timeStamp
  })

// 1. Create Resource Group
module rg 'modules/rg.bicep' = {
  name: 'rg-wg-${code}'
  params: {
    code: code
    location: location
    tags: xtags
  }
}

// 2. Create Virtual Network
module vnet 'modules/vnet.bicep' = {
  name: 'vnet-wg-${code}'
  params: {
    code: code
    location: location
    tags: xtags
  }
  dependsOn: [
    rg
  ]
  scope: resourceGroup(rg.name)
}

// 3. Deloy Linux VM with WireGuard
module vm 'modules/vm.bicep' = {
  name: 'vm-wg-${code}'
  params: {
    code: code
    location: location
    tags: xtags
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
  dependsOn: [
    vnet
  ]
  scope: resourceGroup(rg.name)
}

// Output FQDN
output fqdn string = vm.outputs.fqdn
