data "azurerm_virtual_network" "core" {
  name                 = var.core_vnet
  resource_group_name = "DELRG"
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = var.core_vnet
  resource_group_name  = "DELRG"
  address_prefixes     = [local.bastion_subnet_address_prefix]
}

resource "azurerm_subnet" "azure_firewall" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = var.core_vnet
  resource_group_name  = "DELRG"
  address_prefixes     = [local.firewall_subnet_address_space]
}

resource "azurerm_subnet" "shared" {
  name                 = "SharedSubnet"
  virtual_network_name = var.core_vnet
  resource_group_name  = "DELRG"
  address_prefixes     = [local.shared_services_subnet_address_prefix]
  # notice that private endpoints do not adhere to NSG rules
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}
