resource "azurerm_private_dns_zone_virtual_network_link" "spoke-link" {
  name                  = "${var.service_name}-zone-${var.spoke_prefix}-${var.location}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = var.spoke_vnet_id
}
