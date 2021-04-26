resource "azurerm_virtual_network_peering" "direction1" {
  name                         = "${var.netA_name}-to-${var.netB_name}"
  resource_group_name          = var.resource_group_nameA
  virtual_network_name         = var.netA_name
  remote_virtual_network_id    = var.netB_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}
