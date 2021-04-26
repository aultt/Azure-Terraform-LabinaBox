resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.gateway_address_prefix]
}

resource "azurerm_local_network_gateway" "onpremise" {
  name                = var.local_network_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.gateway_ip_address
  address_space       = var.local_network_gateway_prefix
}

resource "azurerm_public_ip" "pip" {
  name                = var.gateway_pip_name
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = var.gateway_name
  location            = azurerm_public_ip.pip.location
  resource_group_name = azurerm_public_ip.pip.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GatewaySubnet.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "s2s-conn" {
  name                = var.s2s_connection_name
  location            = azurerm_virtual_network_gateway.gateway.location
  resource_group_name = azurerm_virtual_network_gateway.gateway.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.onpremise.id

  shared_key = var.shared_key
}

