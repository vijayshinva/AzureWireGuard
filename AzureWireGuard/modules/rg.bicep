targetScope = 'subscription'

param code string
param location string
param tags object

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-wg-${code}'
  location: location
  tags: tags
}

output id string = resourceGroup.id
output name string = resourceGroup.name
