data "azurerm_resource_group" "core" {
  name = var.resource_group_name
}

data "azurerm_network_service_tags" "storage" {
  location        = data.azurerm_resource_group.core.location
  service         = "Storage"
  location_filter = data.azurerm_resource_group.core.location
}

locals {
  allowed_aml_urls     = ["ml.azure.com", "viennaglobal.azurecr.io", "*openml.org"]
  allowed_ad_urls      = ["enterpriseregistration.windows.net", "169.254.169.254", "login.microsoftonline.com", "pas.windows.net", "*manage-beta.microsoft.com", "*manage.microsoft.com", "login.windows.net,","msft.sts.microsoft.com"]
  allowed_general_urls = ["binstar-cio-packages-prod.s3.amazonaws.com", "conda.anaconda.org", "repo.anaconda.com", "azure.archive.ubuntu.com", "go.microsoft.com", "*.azureedge.net", "*github.com", "*githubassets.com", "*powershellgallery.com", "git-scm.com", "*githubusercontent.com", "*core.windows.net", "aka.ms", "management.azure.com", "graph.microsoft.com", "login.microsoftonline.com", "aadcdn.msftauth.net", "graph.windows.net"]
  allowed_InnerEye_urls  = ["*.anaconda.com", "*.anaconda.org", "binstar-cio-packages-prod.s3.amazonaws.com", "*pythonhosted.org", "github-cloud.githubusercontent.com", "azure.archive.ubuntu.com", "packagecloud.io", "*pypi.org"]
  allowed_service_tags = [data.azurerm_network_service_tags.storage.id, "AzureContainerRegistry"]
}
