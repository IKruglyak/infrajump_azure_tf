output "app_url" {
  value = "https://${azurerm_app_service.this.default_site_hostname}"
}