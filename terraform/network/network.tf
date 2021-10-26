resource "azurerm_virtual_network" "core" {
  name                = "vnet-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.core.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [local.bastion_subnet_address_prefix]
}

resource "azurerm_subnet" "azure_firewall" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = azurerm_virtual_network.core.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [local.firewall_subnet_address_space]
}

resource "azurerm_subnet" "shared" {
  name                 = "SharedSubnet"
  virtual_network_name = azurerm_virtual_network.core.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [local.shared_services_subnet_address_prefix]
  # notice that private endpoints do not adhere to NSG rules
  enforce_private_link_endpoint_network_policies = true
}
