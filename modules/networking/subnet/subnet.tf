resource "azurerm_subnet" "vnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes       = var.subnet_prefixes
  enforce_private_link_endpoint_network_policies = true
}
resource "azurerm_network_security_group" "subnet" { 
    name                        = "${var.subnet_name}-subnet-nsg"
    location                    = var.location
    resource_group_name         = azurerm_subnet.vnet.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.vnet.id
  network_security_group_id = azurerm_network_security_group.subnet.id
}