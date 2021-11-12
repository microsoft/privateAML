resource "azurerm_storage_account" "stg" {
  name                     = lower(replace("stg-${var.name}", "-", ""))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action = "Deny"
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "filecore" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "filecorelink" {
  name                  = "filecorelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.filecore.name
  virtual_network_id    = var.core_vnet

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "blobcore" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "blobcore" {
  name                  = "blobcorelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blobcore.name
  virtual_network_id    = var.core_vnet

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_endpoint" "blobpe" {
  name                = "pe-blob-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.shared_subnet

  lifecycle { ignore_changes = [tags] }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-blobcore"
    private_dns_zone_ids = [azurerm_private_dns_zone.blobcore.id]
  }

  private_service_connection {
    name                           = "psc-stg-${var.name}"
    private_connection_resource_id = azurerm_storage_account.stg.id
    is_manual_connection           = false
    subresource_names              = ["Blob"]
  }
}

resource "azurerm_private_endpoint" "filepe" {
  name                = "pe-file-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.shared_subnet

  lifecycle { ignore_changes = [tags] }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-filecore"
    private_dns_zone_ids = [azurerm_private_dns_zone.filecore.id]
  }

  private_service_connection {
    name                           = "psc-filestg-${var.name}"
    private_connection_resource_id = azurerm_storage_account.stg.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}