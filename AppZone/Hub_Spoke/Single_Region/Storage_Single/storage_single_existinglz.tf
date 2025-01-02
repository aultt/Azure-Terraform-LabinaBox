terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.0.0"
      configuration_aliases = [ azurerm.poc ]
    }
  }
}
provider "azurerm" {
    resource_provider_registrations = "none"
    subscription_id = var.poc_subscription_id
    features {} 
} 
provider "azurerm" {
    features {} 
    alias = "poc"
    subscription_id = var.poc_subscription_id
}

data "azurerm_virtual_network" "lz_spk_region1" {
  provider = azurerm.poc
  name                = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_subnet" "lz_default_subnet_region1" {
  provider = azurerm.poc
  name                 = "default"
  resource_group_name  = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
}

data "azurerm_private_dns_zone" "storage" {
  provider = azurerm.poc
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
}
data "azurerm_virtual_network" "hub_region1" {
  provider = azurerm.poc
  name                = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
}

module "storage" {
  source                          = "../../../../modules/storage/private"
  resource_group_name             = data.azurerm_virtual_network.lz_spk_region1.resource_group_name
  location                        = data.azurerm_virtual_network.lz_spk_region1.location
  storage_prefix                  = "corp"
  subnet_id                       = data.azurerm_subnet.lz_default_subnet_region1.id
  storage_zone_name               = "privatelink.blob.core.windows.net"
  storage_zone_id                 = data.azurerm_private_dns_zone.storage.id
}