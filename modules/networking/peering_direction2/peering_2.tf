resource "azurerm_virtual_network_peering" "direction2" {
  name                         = "${var.netB_name}-to-${var.netA_name}"
  resource_group_name          = var.resource_group_nameB
  virtual_network_name         = var.netB_name
  remote_virtual_network_id    = var.netA_id
  allow_virtual_network_access = var.vnet_access
  allow_forwarded_traffic      = var.forward_traffic
  allow_gateway_transit        = var.gateway_transit
  use_remote_gateways          = var.remote_gateways

}