provider "azurerm" {
  features {}
}

data "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
}

module "webapp_meals" {
  source                      = "../../modules/webapp"
  app_name                    = var.app_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  app_service_plan_id         = data.azurerm_app_service_plan.asp.id
  access_restrictions_enabled = var.access_restrictions_enabled
}