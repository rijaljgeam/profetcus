variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "server_name" { type = string }
variable "database_name" { type = string }

variable "administrator_login" {
  type      = string
  sensitive = true
}

variable "administrator_password" {
  type      = string
  sensitive = true
}