resource "azurerm_container_registry" "acr" {
  name                          = "acr${var.name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = "Premium"
  admin_enabled                 = false
  
  # Public network access is left as allowed due to the bug in AML not being able to access restricted ACR at this time 
  # public_network_access_enabled = false

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "azurecr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "acrlink" {
  name                  = "acrcorelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.azurecr.name
  virtual_network_id    = var.core_vnet

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_endpoint" "acrpe" {
  name                = "acrpe-${azurerm_container_registry.acr.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.shared_subnet

  lifecycle { ignore_changes = [tags] }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.azurecr.id]
  }

  private_service_connection {
    name                           = "acrpesc-${azurerm_container_registry.acr.name}"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}