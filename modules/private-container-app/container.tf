resource "azurerm_container_app_environment" "environment" {
  name                       = "${var.container_app_name}-env"
  location                   = local.location
  resource_group_name        = local.resource_group_name
  infrastructure_subnet_id   = azurerm_subnet.private_subnet.id
  tags                       = var.tags

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "D4"
  }
}

resource "azurerm_container_app" "app" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.environment.id
  resource_group_name          = local.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = var.container_app_name
      image  = var.container_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "WEBSITES_PORT"
        value = "443"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port     = 443
    transport       = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.tags
} 