# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.9.0"
    }
  }

}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

resource "azurerm_resource_group" "core" {
  location = var.location
  name     = "rg-${local.name}"
  tags = {
    project = "Private Azure ML"
    name    = local.name
    source  = "https://github.com/microsoft/privateAML/"
  }

  lifecycle { ignore_changes = [tags] }
}

module "azure_monitor" {
  source              = "./azure-monitor"
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.core.name
}

module "network" {
  source              = "./network"
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.core.name
  vnet_address_space  = var.vnet_address_space
  log_analytics_workspace_id = module.azure_monitor.log_analytics_workspace_id  
}

module "storage" {
  source              = "./storage"
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.core.name
  shared_subnet       = module.network.shared_subnet_id
  core_vnet           = module.network.core_vnet_id
  log_analytics_workspace_id = module.azure_monitor.log_analytics_workspace_id

  depends_on = [
    module.network
  ]
}

module "keyvault" {
  source              = "./keyvault"
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.core.name
  shared_subnet       = module.network.shared_subnet_id
  core_vnet           = module.network.core_vnet_id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  log_analytics_workspace_id = module.azure_monitor.log_analytics_workspace_id
}

module "firewall" {
  source                     = "./firewall"
  name                       = local.name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.core.name
  log_analytics_workspace_id = module.azure_monitor.log_analytics_workspace_id

  depends_on = [
    module.network
  ]
}

module "routetable" {
  source                      = "./routetable"
  name                        = local.name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.core.name
  shared_subnet               = module.network.shared_subnet_id
  firewall_private_ip_address = module.firewall.firewall_private_ip_address
}

module "bastion" {
  source              = "./bastion"
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.core.name
  bastion_subnet      = module.network.bastion_subnet_id
  log_analytics_workspace_id = module.azure_monitor.log_analytics_workspace_id
}

module "acr" {
  source              = "./acr"
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.core.name
  shared_subnet       = module.network.shared_subnet_id
  core_vnet           = module.network.core_vnet_id
  log_analytics_workspace_id = module.azure_monitor.log_analytics_workspace_id
}

module "aml" {
  source                  = "./aml"
  name                    = local.name
  location                = var.location
  resource_group_name     = azurerm_resource_group.core.name
  shared_subnet           = module.network.shared_subnet_id
  application_insights_id = module.azure_monitor.app_insights_id
  key_vault_id            = module.keyvault.key_vault_id
  storage_account_id      = module.storage.storage_account_id
  container_registry_id   = module.acr.id
  core_vnet               = module.network.core_vnet_id
  log_analytics_workspace_id = module.azure_monitor.log_analytics_workspace_id
}

module "jumpbox" {
  source              = "./admin-jumpbox"
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.core.name
  shared_subnet       = module.network.shared_subnet_id
  key_vault_id        = module.keyvault.key_vault_id
  log_analytics_workspace_id = module.azure_monitor.log_analytics_workspace_id  
  depends_on = [
    module.keyvault
  ]
}
