resource "azurerm_service_plan" "compute" {
  name                = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type      = "Linux"            # replaces reserved/kind
  sku_name     = "B1"               # Basic B1 plan
  worker_count = var.instance_count # number of workers/instances
}

resource "azurerm_linux_web_app" "compute" {
  name                = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.compute.id

  identity {
    type = "SystemAssigned" # Enables MSI
  }

  site_config {
    always_on = true
    application_stack {
      docker_image_name   = var.container_image       # "jegamrijal42/jegamrijal:quoteapi1"
      docker_registry_url = "https://index.docker.io" # Docker Hub
    }
  }

  app_settings = {
    "DOCKER_ENABLE_CI"                    = "true"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITES_PORT"                       = "8000" # Match container's exposed port
    "NODE_ENV"                            = "production"
    "ConnectionStrings__Default"          = "@Microsoft.KeyVault(SecretUri=${var.secret_uri})"
  }
}