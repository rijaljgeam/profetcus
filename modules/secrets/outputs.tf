output "db_connection_secret_uri" {
  description = "Key Vault secret URI for database connection"
  value       = azurerm_key_vault_secret.db_connection.id
}

output "key_vault_id" {
  description = "Key Vault resource ID"
  value       = azurerm_key_vault.kv.id
}

