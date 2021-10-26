output "core_resource_group_name" {
  value = azurerm_resource_group.core.name
}

output "log_analytics_name" {
  value = module.azure_monitor.log_analytics_workspace_name
}

output "keyvault_name" {
  value = module.keyvault.keyvault_name
}

output "jumpbox_user" {
  value = module.jumpbox.jumpbox_user
}

output "jumpbox_pass" {
  value     = module.jumpbox.jumpbox_password
  sensitive = true
}