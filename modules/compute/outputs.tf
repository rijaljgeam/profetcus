output "app_url" {
  value       = "https://${azurerm_linux_web_app.compute.default_hostname}"
  description = "Public URL of the deployed application"
}

output "app_service_plan_id" {
  value       = azurerm_service_plan.compute.id
  description = "App Service Plan ID"
}

output "app_principal_id" {
  description = "The principal (object) ID of the System Assigned Managed Identity"
  value       = azurerm_linux_web_app.compute.identity[0].principal_id
}

output "app_id" {
  description = "The resource ID of the Linux Web App"
  value       = azurerm_linux_web_app.compute.id
}
