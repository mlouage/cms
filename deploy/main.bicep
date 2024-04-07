targetScope = 'subscription'

param location string = 'westeurope'
param imageTag string = 'latest'

var resourceGroupName = 'rg-xprtzbv-website'
var containerAppIdentityName = 'id-xprtzbv-website'
var frontDoorEndpointName = 'fde-xprtzbv-cms'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource containerAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup
  name: containerAppIdentityName
}

module containerAppCms 'modules/container-app-website.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Container-App-Cms'
  params: {
    location: location
    containerAppUserAssignedIdentityResourceId: containerAppIdentity.id
    containerAppUserAssignedIdentityClientId: containerAppIdentity.properties.clientId
    imageTag: imageTag
  }
}

module frontDoor 'modules/front-door.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Front-Door'
  params: {
    frontDoorEndpointName: frontDoorEndpointName
    originHostname: containerAppCms.outputs.containerAppUrl
  }
}
