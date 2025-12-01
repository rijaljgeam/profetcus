resource "azurerm_postgresql_flexible_server" "db" {
  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  # Storage & Performance
  storage_mb = 32768             # 32GB
  sku_name   = "B_Standard_B1ms" # 1 vCPU, 2GB RAM
  version    = "14"

  # Networking
  public_network_access_enabled = true # Allow Azure services
  # WARNING: Opens the server to the internet. Prefer scoped ranges in prod.


  # Backup Policy
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  zone = 1

  lifecycle {
    ignore_changes = [
      version,
      zone,
      # Allow network changes if needed
    ]
  }

}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "allow-all"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}