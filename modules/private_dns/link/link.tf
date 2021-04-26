resource "azurerm_private_dns_zone_virtual_network_link" "hub-link" {
  name                  = "${var.service_name}-zone-hub-${var.location}link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = var.hub_vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-link" {
  name                  = "${var.service_name}-zone-spoke-${var.location}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = var.spoke_vnet_id
}
