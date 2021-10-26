output "app_insights_instrumentation_key" {
  value = azurerm_application_insights.core.instrumentation_key
}

output "app_insights_connection_string" {
  value = azurerm_application_insights.core.connection_string
}

output "app_insights_id" {
  value = azurerm_application_insights.core.id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.core.id
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.core.name
}
