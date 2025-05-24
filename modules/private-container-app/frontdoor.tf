# Front Door is not used due to subscription quota limitations.
# Instead, we're using Application Gateway as the single entry point.
# This provides better security and simpler architecture.

resource "azurerm_cdn_frontdoor_profile" "front_door" {
  name                = var.front_door_name
  resource_group_name = local.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "front_door_endpoint" {
  name                     = "${var.front_door_name}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "front_door_origin_group" {
  name                     = "${var.front_door_name}-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "app_gateway" {
  name                          = "app-gateway-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.front_door_origin_group.id
  enabled                       = true

  host_name          = azurerm_application_gateway.app_gateway.frontend_ip_configuration[0].public_ip_address_id
  http_port          = 80
  https_port         = 443
  origin_host_header = azurerm_container_app.app.ingress[0].fqdn
  priority           = 1
  weight             = 1000

  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "front_door_route" {
  name                          = "${var.front_door_name}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.front_door_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.front_door_origin_group.id
  enabled                       = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cdn_frontdoor_rule_set_ids = []
  cdn_frontdoor_origin_ids   = [azurerm_cdn_frontdoor_origin.app_gateway.id]
} 