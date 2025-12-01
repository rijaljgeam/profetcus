provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

resource "random_password" "postgres_admin" {
  length           = 20
  special          = true
  override_special = "_%@!#-"
  keepers = {
    # Only regenerates when you change this value
    version = "v1" # Change to "v2" when you want to rotate
  }
}

module "network" {
  source              = "./modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "compute" {
  depends_on          = [module.network]
  subscription_id     = var.subscription_id
  source              = "./modules/compute"
  secret_uri          = module.secrets.db_connection_secret_uri
  app_name            = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  instance_count      = var.instance_count
  container_image     = var.container_image
}

module "data" {
  depends_on             = [module.network]
  source                 = "./modules/data"
  resource_group_name    = var.resource_group_name
  location               = var.location
  server_name            = var.server_name
  database_name          = var.database_name
  administrator_login    = var.administrator_login
  administrator_password = random_password.postgres_admin.result
}

module "secrets" {
  depends_on          = [module.network]
  source              = "./modules/secrets"
  resource_group_name = var.resource_group_name
  location            = var.location
  keyvault_prefix     = var.keyvault_prefix
  app_principal_id    = module.compute.app_principal_id

  # Database connection details
  db_fqdn     = module.data.db_fqdn
  db_name     = module.data.db_name
  db_username = module.data.administrator_login
  db_password = random_password.postgres_admin.result
}

module "logging" {
  depends_on           = [module.compute, module.data]
  source               = "./modules/logging"
  app_id               = module.compute.app_id
  db_id                = module.data.db_id
  resource_group_name  = var.resource_group_name
  location             = var.location
  QuoteAPILogAnalytics = var.QuoteAPILogAnalytics
  QuoteApiHttpLogs     = var.QuoteApiHttpLogs
  QuoteApiDatabaseLogs = var.QuoteApiDatabaseLogs
}
