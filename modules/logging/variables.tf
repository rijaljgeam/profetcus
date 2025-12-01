variable "QuoteApiHttpLogs" {
  type        = string
  description = "Number of App Service instances"
}

variable "QuoteApiDatabaseLogs" {
  type        = string
  description = "Number of App Service instances"
}

variable "location" {
  type        = string
  description = "default location australia east"
}

variable "resource_group_name" {
  type        = string
  description = "Default QuoteAPI ResourceGroup"
}

variable "QuoteAPILogAnalytics" {
  type        = string
  description = "Number of App Service instances"
}

variable "app_id" {
  description = "The App Service resource ID"
  type        = string
}

variable "db_id" {
  description = "The PostgreSQL database resource ID"
  type        = string
}