terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.54"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "e41e0c9f-a4e9-4b2c-af90-a5bd668f2229"
}

# Get current Azure context
data "azurerm_client_config" "current" {}

# Create resource group
resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate"
  location = "australiaeast"
}

# Generate random suffix for unique name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
  keepers = {
    # Only regenerates when you change this value
    version = "v1" # Change to "v2" to force new suffix
  }
}

# Storage account
resource "azurerm_storage_account" "tfstate" {
  name                            = "terraformfstate${random_string.storage_suffix.result}"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    Purpose     = "Terraform State Storage"
    Environment = "Shared"
    ManagedBy   = "Terraform"
  }
}

# Blob container
resource "azurerm_storage_container" "tfstate" {
  name                  = "terraformfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# Generate SAS token for backend use
# Using a fixed start date for true idempotency
locals {
  # Fixed token validity period - change this date to regenerate token
  sas_start  = "2025-11-27T00:00:00Z"
  sas_expiry = "2026-11-27T00:00:00Z"
}

data "azurerm_storage_account_sas" "tfstate_sas" {
  connection_string = azurerm_storage_account.tfstate.primary_connection_string
  https_only        = true

  # Fixed dates for idempotency - won't change on subsequent applies
  start  = local.sas_start
  expiry = local.sas_expiry

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    tag     = false
    filter  = false
    process = false
  }

  services {
    blob  = true
    file  = false
    queue = false
    table = false
  }

  resource_types {
    service   = true
    container = true
    object    = true
  }
}

# Auto-generate backend.hcl file on apply
resource "local_file" "backend_config" {
  filename        = "${path.module}/../backend.hcl"
  file_permission = "0600"
  content         = <<-EOT
# Auto-generated backend configuration
# DO NOT EDIT MANUALLY 
storage_account_name = "${azurerm_storage_account.tfstate.name}"
container_name       = "${azurerm_storage_container.tfstate.name}"
resource_group_name  = "${azurerm_resource_group.tfstate.name}"
key                  = "terraform.tfstate"
sas_token            = "${data.azurerm_storage_account_sas.tfstate_sas.sas}"
  EOT
}

# Outputs
output "subscription_id" {
  description = "The Azure subscription ID being used"
  value       = data.azurerm_client_config.current.subscription_id
}

output "tenant_id" {
  description = "The Azure tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "The name of the blob container"
  value       = azurerm_storage_container.tfstate.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.tfstate.name
}

output "sas_token" {
  description = "SAS token for the storage account blob service"
  value       = data.azurerm_storage_account_sas.tfstate_sas.sas
  sensitive   = true
}

output "primary_access_key" {
  description = "Primary access key for the storage account (alternative to SAS)"
  value       = azurerm_storage_account.tfstate.primary_access_key
  sensitive   = true
}

output "backend_config_file" {
  description = "Path to the auto-generated backend configuration file"
  value       = local_file.backend_config.filename
}

output "backend_init_command" {
  description = "Command to initialize Terraform with the generated backend"
  value       = "terraform init -backend-config=${local_file.backend_config.filename} -reconfigure"
}