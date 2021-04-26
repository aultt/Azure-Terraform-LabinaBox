resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.address_space] 
  dns_servers         = var.dns_servers
  tags                = var.tags

}

resource "azurerm_subnet" "vnet" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes       = var.default_subnet_prefixes

  depends_on = [azurerm_virtual_network.vnet]
}





