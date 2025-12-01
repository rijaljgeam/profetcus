# Output from compute module
output "app_url" {
  description = "The URL of the deployed application"
  value       = module.compute.app_url
}