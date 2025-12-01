variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "keyvault_prefix" { type = string }
variable "db_fqdn" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "app_principal_id" {
  description = "Object ID of the App Service system-assigned managed identity"
  type        = string
}
