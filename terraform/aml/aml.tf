resource "azurerm_machine_learning_workspace" "ml" {
  name                    = "ml-${var.name}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = var.application_insights_id
  key_vault_id            = var.key_vault_id
  storage_account_id      = var.storage_account_id
  identity {
    type = "SystemAssigned"
  }

  lifecycle { ignore_changes = [tags] }
}

data "azurerm_private_dns_zone" "azureml" {
  name                = "privatelink.api.azureml.ms"
  resource_group_name = var.resource_group_name
}

data "azurerm_private_dns_zone" "azuremlcert" {
  name                = "privatelink.cert.api.azureml.ms"
  resource_group_name = var.resource_group_name
}

data "azurerm_private_dns_zone" "notebooks" {
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "mlpe" {
  name                = "mlpe-${azurerm_machine_learning_workspace.ml.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.shared_subnet

  lifecycle { ignore_changes = [tags] }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.azureml.id, data.azurerm_private_dns_zone.notebooks.id, data.azurerm_private_dns_zone.azuremlcert.id]
  }

  private_service_connection {
    name                           = "mlpesc-${azurerm_machine_learning_workspace.ml.name}"
    private_connection_resource_id = azurerm_machine_learning_workspace.ml.id
    is_manual_connection           = false
    subresource_names              = ["amlworkspace"]
  }
}
