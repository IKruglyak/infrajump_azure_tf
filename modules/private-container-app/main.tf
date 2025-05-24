terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

locals {
  location            = var.resource_group_location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.container_app_name}-law"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
} 