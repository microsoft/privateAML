# Network security group for Azure Bastion subnet
# See https://docs.microsoft.com/azure/bastion/bastion-nsg
resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-bastion-subnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowInboundInternet"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInboundGatewayManager"
    priority                   = 4001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInboundAzureLoadBalancer"
    priority                   = 4002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInboundHostCommunication"
    priority                   = 4003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["5701", "8080"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowOutboundSshRdp"
    priority                   = 4020
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowOutboundAzureCloud"
    priority                   = 4021
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "AllowOutboundHostCommunication"
    priority                   = 4022
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["5701", "8080"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowOutboundGetSessionInformation"
    priority                   = 4023
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_network_security_group" "shared_rules" {
  name                = "nsg-shared"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "shared" {
  subnet_id                 = azurerm_subnet.shared.id
  network_security_group_id = azurerm_network_security_group.shared_rules.id
}

resource "azurerm_network_security_rule" "allow-batch-inbound" {
  access                      = "Allow"
  destination_port_ranges     = ["29876", "29877"]
  destination_address_prefix  = "VirtualNetwork"
  source_address_prefix       = "BatchNodeManagement"
  direction                   = "Inbound"
  name                        = "allow-Batch-inbound"
  network_security_group_name = azurerm_network_security_group.shared_rules.name
  priority                    = 200
  protocol                    = "TCP"
  resource_group_name         = var.resource_group_name
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "allow-aml-inbound" {
  access                      = "Allow"
  destination_port_ranges     = ["44224"]
  destination_address_prefix  = "VirtualNetwork"
  source_address_prefix       = "Internet"
  direction                   = "Inbound"
  name                        = "allow-AzureML-inbound"
  network_security_group_name = azurerm_network_security_group.shared_rules.name
  priority                    = 201
  protocol                    = "TCP"
  resource_group_name         = var.resource_group_name
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "allow-Outbound_Storage_445" {
  access                      = "Allow"
  destination_port_range      = "445"
  destination_address_prefix  = "Storage"
  source_address_prefix       = "VirtualNetwork"
  direction                   = "Outbound"
  name                        = "allow-Outbound-Storage-445"
  network_security_group_name = azurerm_network_security_group.shared_rules.name
  priority                    = 202
  protocol                    = "TCP"
  resource_group_name         = var.resource_group_name
  source_port_range           = "*"
}