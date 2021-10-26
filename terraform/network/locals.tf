locals {
  core_services_vnet_subnets            = cidrsubnets(var.vnet_address_space, 4, 4, 4, 4, 2, 2, 2)
  firewall_subnet_address_space         = local.core_services_vnet_subnets[0] # .0 - .62
  bastion_subnet_address_prefix         = local.core_services_vnet_subnets[2] # .128 - .191
  shared_services_subnet_address_prefix = local.core_services_vnet_subnets[4] # .0 - .254
}
