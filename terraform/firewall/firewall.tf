resource "azurerm_public_ip" "fwpip" {
  name                = "pip-fw-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_firewall" "fw" {
  depends_on          = [azurerm_public_ip.fwpip]
  name                = "fw-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                 = "fw-ip-configuration"
    subnet_id            = data.azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.fwpip.id
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "diagnostics-firewall-${var.name}"
  target_resource_id         = azurerm_firewall.fw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log_analytics_destination_type = "AzureDiagnostics"
  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true


    retention_policy {
      enabled = false
      days    = 0
    }
  }

  log {

    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
  log {

    category = "AzureFirewallDnsProxy"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
  log {

    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
  
}

resource "azurerm_firewall_application_rule_collection" "shared_subnet" {
  name                = "arc-shared_subnet"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_firewall.fw.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "admin-resources"
    source_addresses = data.azurerm_subnet.shared.address_prefixes
    target_fqdns     = local.allowed_general_urls

    protocol {
      port = "443"
      type = "Https"
    }

    protocol {
      port = "80"
      type = "Http"
    }


  }

  rule {
    name             = "allowMLrelated"
    source_addresses = data.azurerm_subnet.shared.address_prefixes
    target_fqdns     = local.allowed_aml_urls

    protocol {
      port = "443"
      type = "Https"
    }

    protocol {
      port = "80"
      type = "Http"
    }
  }

  rule {
    name             = "allowADrelated"
    source_addresses = data.azurerm_subnet.shared.address_prefixes
    target_fqdns     = local.allowed_ad_urls

    protocol {
      port = "443"
      type = "Https"
    }

    protocol {
      port = "80"
      type = "Http"
    }
  }

  rule {
    name             = "allowInnerEyerelated"
    source_addresses = data.azurerm_subnet.shared.address_prefixes
    target_fqdns     = local.allowed_InnerEye_urls

    protocol {
      port = "443"
      type = "Https"
    }

    protocol {
      port = "80"
      type = "Http"
    }
  }

}

resource "azurerm_firewall_network_rule_collection" "general" {
  name                = "general"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_firewall.fw.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name = "time"

    protocols = [
      "UDP"
    ]

    destination_addresses = [
      "*"
    ]

    destination_ports = [
      "123"
    ]
    source_addresses = [
      "*"
    ]
  }

  depends_on = [
    azurerm_firewall_application_rule_collection.shared_subnet
  ]
}

resource "azurerm_firewall_network_rule_collection" "shared_nrc" {
  name                = "shared"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_firewall.fw.resource_group_name
  priority            = 101
  action              = "Allow"

  rule {
    name = "allowStorage"

    source_addresses = data.azurerm_subnet.shared.address_prefixes


    destination_ports = [
      "*"
    ]

    destination_addresses = local.allowed_service_tags

    protocols = [
      "TCP"
    ]
  }

  depends_on = [
    azurerm_firewall_network_rule_collection.general
  ]
}