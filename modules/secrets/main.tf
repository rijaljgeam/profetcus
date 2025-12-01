# Get Azure AD context first
data "azurerm_client_config" "current" {}

# Create Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                       = var.keyvault_prefix
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  # Use access policies instead of RBAC for faster propagation
  rbac_authorization_enabled = false

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

# Access Policy for deployment user (YOU) - must be created BEFORE secrets
resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  # Full permissions for managing secrets during deploy AND destroy
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
}

# Access Policy for App Service Managed Identity
resource "azurerm_key_vault_access_policy" "app_managed_identity" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.app_principal_id

  # App only needs to read secrets
  secret_permissions = ["Get", "List"]
}

# Create Connection String Secret - AFTER access policies are set
resource "azurerm_key_vault_secret" "db_connection" {
  name         = "DB-CONNECTION-STRING"
  content_type = "connection-string"
  # Expire in 1 year from now
  value        = "Server=${var.db_fqdn};Database=${var.db_name};User Id=${var.db_username};Password=${var.db_password};Port=5432;Encrypt=true;TrustServerCertificate=off;"
  key_vault_id = azurerm_key_vault.kv.id

  not_before_date = "2025-11-26T00:00:00Z"
  expiration_date = "2026-11-26T00:00:00Z"

  # Ensure access policy exists before creating secret
  depends_on = [
    azurerm_key_vault_access_policy.deployer
  ]
}