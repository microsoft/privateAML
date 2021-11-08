data "azurerm_resource_group" "core" {
  name = var.resource_group_name
}

data "azurerm_network_service_tags" "storage" {
  location        = data.azurerm_resource_group.core.location
  service         = "Storage"
  location_filter = data.azurerm_resource_group.core.location
}

locals {
  allowed_aml_urls     = ["ml.azure.com", "viennaglobal.azurecr.io"]
  allowed_general_urls = ["go.microsoft.com", "*.azureedge.net", "*github.com", "*githubassets.com", "*powershellgallery.com", "git-scm.com", "*githubusercontent.com", "*core.windows.net", "aka.ms", "management.azure.com", "graph.microsoft.com", "login.microsoftonline.com", "aadcdn.msftauth.net", "graph.windows.net"]
  allowed_service_tags = ["${data.azurerm_network_service_tags.storage.id}", "AzureContainerRegistry"]
}
