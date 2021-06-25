resource "azurerm_automation_account" "aa" {
  name                = var.name
  location            = var.automation_location
  resource_group_name = var.resource_group_name

  sku_name = "Basic"

  tags = {
    "Workload" = "Core Infra"
    "Data Class" = "General"
    "Business Crit" = "Low"
  }
  
}

resource "azurerm_log_analytics_linked_service" "law_link" {
  resource_group_name = var.resource_group_name
  workspace_id        = var.law_id
  read_access_id      = azurerm_automation_account.aa.id
}

resource "azurerm_log_analytics_solution" "lawsolutionupdates" {
  solution_name         = "Updates"
  location              = var.law_location
  resource_group_name   = azurerm_automation_account.aa.resource_group_name
  workspace_resource_id = var.law_id
  workspace_name        = var.law_name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

resource "azurerm_log_analytics_solution" "lawsolutionchange" {
  solution_name         = "ChangeTracking"
  location              = var.law_location
  resource_group_name   = azurerm_automation_account.aa.resource_group_name
  workspace_resource_id = var.law_id
  workspace_name        = var.law_name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ChangeTracking"
  }
}

resource "azurerm_log_analytics_solution" "la-opf-solution-sentinel" {
  solution_name         = "SecurityInsights"
  location              = var.law_location
  resource_group_name   = azurerm_automation_account.aa.resource_group_name
  workspace_resource_id = var.law_id
  workspace_name        = var.law_name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}
