
data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_key_vault" "vault" {
  name                = var.keyvault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules = [
      "${chomp(data.http.myip.response_body)}/32"
  ]
 
  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = ["Backup", "Create", "Delete", "Get"]

    key_permissions = ["List", "Encrypt", "Decrypt", "WrapKey", "UnwrapKey", "Sign", "Verify", "Get","Create", "Update"]

    secret_permissions = ["List", "Get", "Set", "Backup", "Restore", "Recover", "Purge", "Delete"]

    storage_permissions = ["Backup", "Get", "Recover", "List"]
  }

}

resource "azurerm_private_endpoint" "keyvault-endpoint" {
  name                = "keyvault-${var.location}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.shared_subnetid

  private_service_connection {
    name                           = "kv-private-link-connection"
    private_connection_resource_id = azurerm_key_vault.vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                          = var.keyvault_zone_name
    private_dns_zone_ids          = [ var.keyvault_zone_id ]
  }     
}