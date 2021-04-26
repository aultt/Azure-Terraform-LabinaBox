output log_analytics_id {
    description     = "log analytics workspace ID"
    value = azurerm_log_analytics_workspace.law.id
}
output log_analytics_name {
    description     = "log analytics name"
    value = azurerm_log_analytics_workspace.law.name
}
