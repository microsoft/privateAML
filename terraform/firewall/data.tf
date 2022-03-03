data "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = "sharedVNET"

  resource_group_name = "DELRG"
}

data "azurerm_subnet" "shared" {
  name                 = "SharedSubnet"
  virtual_network_name = "sharedVNET"

  resource_group_name = "DELRG"
}
