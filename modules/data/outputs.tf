output "db_fqdn" {
  value       = azurerm_postgresql_flexible_server.db.fqdn
  description = "Database server FQDN"
}

output "db_name" {
  value       = azurerm_postgresql_flexible_server_database.db.name
  description = "Database name"
}

output "administrator_login" {
  value     = var.administrator_login
  sensitive = true
}

output "db_id" {
  description = "The resource ID of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.db.id
}