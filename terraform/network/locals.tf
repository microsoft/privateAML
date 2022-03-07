locals {
  core_services_vnet_subnets            = cidrsubnets(var.vnet_address_space,5, 2, 4, 3)
  firewall_subnet_address_space         = local.core_services_vnet_subnets[1]
  bastion_subnet_address_prefix         = local.core_services_vnet_subnets[2]
  shared_services_subnet_address_prefix = local.core_services_vnet_subnets[3]
}
