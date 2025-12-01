resource "azurerm_log_analytics_workspace" "Log-Analytics" {
  name                = var.QuoteAPILogAnalytics
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ONLY AppServiceHTTPLogs -> LAW
# Fixed: Use module output instead of data source to avoid circular dependency
resource "azurerm_monitor_diagnostic_setting" "http-to-law" {
  name                       = var.QuoteApiHttpLogs
  target_resource_id         = var.app_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.Log-Analytics.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

}

# Diagnostics: PostgreSQL (Flexible) -> LAW
# Used module output instead of data source to avoid circular dependency
resource "azurerm_monitor_diagnostic_setting" "postgres-to-law" {
  name                       = var.QuoteApiDatabaseLogs
  target_resource_id         = var.db_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.Log-Analytics.id

  enabled_log {
    category = "PostgreSQLLogs"
  }


}
