terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "3d2378b7-40d6-4a00-9930-a7171682ed7f"
  tenant_id       = "81ec3e8b-d191-45bc-96e5-b5736a1dd282"
}

module "private_container_app" {
  source = "./modules/private-container-app"

  providers = {
    azurerm = azurerm
  }

  # Resource Group settings
  create_resource_group = true
  resource_group_name   = "private-app-rg"
  location             = "westeurope"

  # Network settings
  vnet_name             = "private-app-vnet"
  vnet_address_space    = "10.0.0.0/16"
  subnet_name           = "private-subnet"
  subnet_address_prefix = "10.0.0.0/23"

  # Container App settings
  container_app_name    = "private-app"
  container_image       = "nginx:latest"

  # Front Door settings
  front_door_name       = "private-app-fd"
  front_door_domain     = "privateapp"

  # Application Gateway settings
  app_gateway_name      = "private-app-gw"
  app_gateway_sku       = "Standard_v2"

  # Log Analytics settings
  log_retention_days    = 30

  # Tags
  tags = {
    Environment = "Production"
    Project     = "PrivateApp"
    ManagedBy   = "Terraform"
  }
} 