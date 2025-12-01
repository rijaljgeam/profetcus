variable "instance_count" {
  type        = number
  description = "Number of App Service instances"
}

variable "container_image" {
  type        = string
  description = "Docker container image"
}

# Reuse global variables
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "app_name" {
  type        = string
  description = "name_prefix"

}

variable "secret_uri" { type = string }

