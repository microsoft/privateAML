data "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = "vnet-${var.name}"

  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "shared" {
  name                 = "SharedSubnet"
  virtual_network_name = "vnet-${var.name}"

  resource_group_name = var.resource_group_name
}
