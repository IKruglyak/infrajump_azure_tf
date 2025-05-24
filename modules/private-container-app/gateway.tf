resource "azurerm_public_ip" "app_gateway_pip" {
  name                = "${var.app_gateway_name}-pip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = var.app_gateway_name
  resource_group_name = local.resource_group_name
  location            = local.location

  sku {
    name     = var.app_gateway_sku
    tier     = var.app_gateway_sku
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.app_gateway_pip.id
  }

  backend_address_pool {
    name = "container-app-pool"
    fqdns = [azurerm_container_app.app.ingress[0].fqdn]
  }

  backend_http_settings {
    name                  = "https-settings"
    cookie_based_affinity = "Disabled"
    port                 = 443
    protocol             = "Https"
    request_timeout      = 60
    probe_name          = "https-probe"
  }

  probe {
    name                = "https-probe"
    protocol            = "Https"
    host                = azurerm_container_app.app.ingress[0].fqdn
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  ssl_certificate {
    name     = "app-gateway-cert"
    data     = filebase64("${path.module}/cert.pfx")
    password = "certificate-password"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name            = "https-port"
    protocol                      = "Https"
    ssl_certificate_name          = "app-gateway-cert"
  }

  request_routing_rule {
    name                       = "https-routing-rule"
    rule_type                 = "Basic"
    http_listener_name        = "https-listener"
    backend_address_pool_name  = "container-app-pool"
    backend_http_settings_name = "https-settings"
    priority                   = 1
  }

  tags = var.tags
} 