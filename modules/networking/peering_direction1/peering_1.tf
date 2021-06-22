resource "azurerm_virtual_network_peering" "direction1" {
  name                         = "${var.netA_name}-to-${var.netB_name}"
  resource_group_name          = var.resource_group_nameA
  virtual_network_name         = var.netA_name
  remote_virtual_network_id    = var.netB_id
  allow_virtual_network_access = var.vnet_access
  allow_forwarded_traffic      = var.forward_traffic
  allow_gateway_transit        = var.gateway_transit
  use_remote_gateways          = var.remote_gateways
}
