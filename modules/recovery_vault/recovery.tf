resource "azurerm_recovery_services_vault" "vault" {
  name                = var.recovery_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "bakpolicy" {
  name                = var.recovery_policy_name
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  
  retention_daily {
    count = 10
  }
}
