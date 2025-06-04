@description('The name of the App Gateway that will be deployed')
param appGatewayName string

@description('The name of the IP address that will be deployed')
param ipAddressName string

@description('The subnet ID that will be used for the App Gateway configuration')
param subnetId string

@description('The subnet ID of the Container App Environment that will be used for the Private Link service')
param envSubnetId string

@description('The FQDN of the Container App')
param containerAppFqdn string


@description('The location where the App Gateway will be deployed')
param location string

@description('The tags that will be applied to the App Gateway')
param tags object

resource appGateway 'Microsoft.Network/applicationGateways@2023-11-01' = {
  name: appGatewayName
  location: location
  tags: tags
  zones: [
    '1'
  ]
  properties: {
    sku: {
      tier: 'Standard_v2'
      capacity: 1
      name: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      { 
        name: 'appgateway-subnet'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      { 
        name: 'zipserve-frontend'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    privateLinkConfigurations: [
      { 
        name: 'zipserve-agw-private-link'
        properties: {
          ipConfigurations: [
            { 
              name: 'privateLinkIpConfig'
              properties: {
                primary: true
                privateIPAllocationMethod: 'Dynamic'
                subnet: {
                  id: subnetId
                }
              }
            }
          ]
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
    ]
    backendAddressPools: [
      {
        name: 'zipserve-agw-backend-pool'
        properties: {
          backendAddresses: [
            { 
              fqdn: containerAppFqdn
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      { 
        name: 'zipserve-agw-backend-setting'
        properties: {
          protocol: 'Https'
          port: 443
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
          pickHostNameFromBackendAddress: true
        }
      }
    ]
    httpListeners: [
      { 
        name: 'zipserve-agw-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'zipserve-frontend')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_80')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      { 
        name: 'zipserve-agw-routing-rule'
        properties: {
          priority: 1
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'zipserve-agw-listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'zipserve-agw-backend-pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'zipserve-agw-backend-setting')
          }
        }
      }
    ]
    enableHttp2: true
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: ipAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: [
    '1'
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}


