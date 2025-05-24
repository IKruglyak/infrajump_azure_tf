output "app_gateway_hostname" {
  description = "Application Gateway hostname"
  value       = azurerm_application_gateway.app_gateway.frontend_ip_configuration[0].public_ip_address_id
}

output "container_app_name" {
  description = "Container App name"
  value       = azurerm_container_app.app.name
}

output "container_app_fqdn" {
  description = "Container App FQDN"
  value       = azurerm_container_app.app.ingress[0].fqdn
}

output "app_gateway_public_ip" {
  description = "Application Gateway public IP"
  value       = azurerm_public_ip.app_gateway_pip.ip_address
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
  description = "Subnet name"
  value       = azurerm_subnet.private_subnet.name
} 