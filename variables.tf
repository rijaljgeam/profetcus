variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "e41e0c9f-a4e9-4b2c-af90-a5bd668f2229"
}

variable "app_name" {
  type        = string
  description = "name_prefix"
  default     = "quoteapi-linux"
}

variable "server_name" {
  type        = string
  description = "name_prefix"
  default     = "quoteapi"
}

variable "container_image" {
  type    = string
  default = "jegamrijal42/jegamrijal:quoteapi1" # Default RG name
}

variable "resource_group_name" {
  type    = string
  default = "quoteapi" # Default RG name
}

variable "location" {
  type    = string
  default = "australiaeast" # Default region
}

variable "database_name" {
  type        = string
  description = "name_prefix"
  default     = "quoteapidata"
}

variable "administrator_login" {
  type        = string
  description = "name_prefix"
  default     = "dbadmin"
}

variable "keyvault_prefix" {
  type        = string
  description = "name_prefix"
  default     = "quoteapi-key"
}

variable "instance_count" {
  type        = number
  default     = 2 # Manual scaling default
  description = "Number of App Service instances"
}


variable "QuoteApiHttpLogs" {
  type        = string
  default     = "QutoeApiHttpLogs"
  description = "Number of App Service instances"
}

variable "QuoteApiDatabaseLogs" {
  type        = string
  default     = "QutoeApiDatabaseLogs"
  description = "Number of App Service instances"
}


variable "QuoteAPILogAnalytics" {
  type        = string
  default     = "QuoteAPILogAnalaytics"
  description = "Number of App Service instances"
}