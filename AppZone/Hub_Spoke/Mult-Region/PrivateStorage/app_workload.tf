terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.52"
    }
  }
}
provider "azurerm" {
    features {} 
}

provider "azurerm" {
    features {} 
    alias = "management"
    subscription_id = var.management_subscription_id
}

provider "azurerm" {
    features {} 
    alias = "identity"
    subscription_id = var.identity_subscription_id
}

provider "azurerm" {
    features {} 
    alias = "connectivity"
    subscription_id = var.connectivity_subscription_id
}

provider "azurerm" {
    features {} 
    alias = "landingzone"
    subscription_id = var.landingzone_subscription_id
}

data "azurerm_virtual_network" "hub_region1" {
  provider = azurerm.connectivity
  name                = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_virtual_network" "hub_region2" {
  provider = azurerm.connectivity
  name                = "${var.hub_vnet_name_prefix}-${var.region2_loc}"
  resource_group_name = "${var.hub_rg_prefix}-${var.region2_loc}-rg"
}
data "azurerm_subnet" "hub_default_subnet" {
  provider = azurerm.connectivity
  name                 = "default"
  resource_group_name  = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
}

data "azurerm_virtual_network" "lz_spk_region1" {
  provider = azurerm.landingzone
  name                = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
}
data "azurerm_subnet" "lz_default_subnet" {
  provider = azurerm.landingzone
  name                 = "default"
  resource_group_name  = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
}

data "azurerm_virtual_network" "lz_spk_region2" {
  provider = azurerm.landingzone
  name                = "${var.lz_vnet_name_prefix}-${var.region2_loc}"
  resource_group_name = "${var.lz_spk_rg_prefix}-${var.region2_loc}-rg"
}

data "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
}

module "shared_storage_account" {
  providers = {azurerm = azurerm.landingzone}
  source                          = "../../../../modules/storage/private"
  resource_group_name             = data.azurerm_virtual_network.lz_spk_region1.resource_group_name
  location                        = var.region1_loc
  storage_prefix                  = "corp"
  subnet_id                       = data.azurerm_subnet.lz_default_subnet.id
  storage_zone_name               = "privatelink.blob.core.windows.net"
  storage_zone_id                 = data.azurerm_private_dns_zone.storage.id
}