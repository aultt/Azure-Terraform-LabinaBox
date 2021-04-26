resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    "Workload" = "Core Infra"
    "Data Class" = "General"
    "Business Crit" = "Low"
  }
}