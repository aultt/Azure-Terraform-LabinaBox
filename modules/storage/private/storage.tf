
#data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "random_string" "random" {
  length = 8
  upper = false
  special = false

}
resource "azurerm_storage_account" "private" {
  name                     = "${var.storage_prefix}sa${random_string.random.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  network_rules {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    #ip_rules = ["${chomp(data.http.myip.body)}/32"]
  }
}

resource "azurerm_private_endpoint" "storage-endpoint" {
  name                = "${var.storage_prefix}-${var.location}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "sa-private-link-connection"
    private_connection_resource_id = azurerm_storage_account.private.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                          = var.storage_zone_name
    private_dns_zone_ids          = [ var.storage_zone_id ]
  }     
}