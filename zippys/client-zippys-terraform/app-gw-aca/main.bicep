targetScope = 'subscription'

@description('The location to deploy all resources to')
param location string = 'westus2'

@description('The suffix applied to all resources')
param appSuffix string = 'zipserve-prod'

@description('The tags to apply to all resources')
param tags object = {
  SampleName: 'aca-app-gateway'
  Owner: 'Zippys'
  Application: 'Azure-Samples'
  Environment: 'Prod'
}

var resourceGroupName = 'zip-serve-prod-be-rg'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module network 'network/virtual-network.bicep' = {
  name: 'vnet'
  scope: rg
  params: {
    location: location 
    tags: tags
    vnetName: '${appSuffix}-vnet'
  }
}

module logAnalytics 'monitoring/log-analytics.bicep' = {
  name: 'law'
  scope: rg
  params: {
    location: location 
    logAnalyticsWorkspaceName: '${appSuffix}-law'
    tags: tags
  }
}

module containerEnv 'host/container-app-env.bicep' = {
  name: 'env'
  scope: rg
  params: {
    acaSubnetId: network.outputs.acaSubnetId 
    envName: '${appSuffix}-env' 
    lawName: logAnalytics.outputs.name
    location: location
    tags: tags
  }
}

module containerApp 'host/container-app.bicep' = {
  name: 'app'
  scope: rg
  params: {
    containerAppEnvName: containerEnv.outputs.containerAppEnvName
    containerAppName: '${appSuffix}-app'
    location: location
    tags: tags
  }
}

module privateDnsZone 'network/private-dns-zone.bicep' = {
  name: 'pdns'
  scope: rg
  params: {
    envDefaultDomain: containerEnv.outputs.domain
    envStaticIp: containerEnv.outputs.staticIp
    tags: tags
    vnetName: network.outputs.name
  }
}

module appGateway 'network/app-gateway.bicep' = {
  name: 'appgateway'
  scope: rg
  params: {
    appGatewayName: '${appSuffix}-agw'
    containerAppFqdn: containerApp.outputs.fqdn
    envSubnetId: network.outputs.acaSubnetId
    ipAddressName: '${appSuffix}-agw-pip'
    location: location

    subnetId: network.outputs.appGatewaySubnetId
    tags: tags
  }
}
