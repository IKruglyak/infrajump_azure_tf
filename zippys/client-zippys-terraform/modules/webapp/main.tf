resource "azurerm_app_service" "this" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    dotnet_framework_version = "v6.0"
  }

  https_only = true
}

resource "azurerm_app_service_access_restriction" "deny_all" {
  count                  = var.access_restrictions_enabled ? 1 : 0
  name                   = "deny-all"
  priority               = 100
  action                 = "Deny"
  rule_type              = "Ip"
  ip_address             = "0.0.0.0/0"
  service_name           = azurerm_app_service.this.name
  resource_group_name    = var.resource_group_name
}