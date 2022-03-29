resource "azurerm_container_registry" "acr" {
  name                = "acr${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Premium"
  admin_enabled       = false

  public_network_access_enabled = false

  network_rule_set {
    default_action = "Allow"
    ip_rule = [
       {
       action = "Allow"
       ip_range = "13.69.64.88/29"
      },
      {
       action = "Allow"
       ip_range = "13.69.106.80/29"
      },
      {
       action = "Allow"
       ip_range = "13.69.110.0/24"
      },
      {
       action = "Allow"
       ip_range = "13.69.110.0/24"
      },
      {
       action = "Allow"
       ip_range = "13.69.112.192/26"
      },
      {
       action = "Allow"
       ip_range = "20.50.200.0/24"
      },
      {
       action = "Allow"
       ip_range = "20.61.97.128/25"
      },
      {
       action = "Allow"
       ip_range = "52.178.18.0/23"
      },
      {
       action = "Allow"
       ip_range = "52.178.20.0/24"
      },
      {
       action = "Allow"
       ip_range = "52.236.186.80/29"
      },
      {
       action = "Allow"
       ip_range = "52.236.191.0/24"
      }
    ]
  }

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

resource "azurerm_monitor_diagnostic_setting" "acrdiagnostic" {
  name                       = "diagnostics-acr-${var.name}"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "ContainerRegistryRepositoryEvents"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "ContainerRegistryLoginEvents"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "acrpediagnostic" {
  name                       = "diagnostics-acr-pe-${var.name}"
  target_resource_id         = azurerm_private_endpoint.acrpe.network_interface[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}
