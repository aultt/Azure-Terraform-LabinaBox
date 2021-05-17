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

data "azurerm_virtual_network" "lz_spk_region1" {
  provider = azurerm.landingzone
  name                = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_subnet" "lz_default_subnet_region1" {
  provider = azurerm.landingzone
  name                 = "default"
  resource_group_name  = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
}

data "azurerm_subnet" "lz_default_subnet_region2" {
  provider = azurerm.landingzone
  name                 = "default"
  resource_group_name  = "${var.lz_spk_rg_prefix}-${var.region2_loc}-rg"
  virtual_network_name = "${var.lz_vnet_name_prefix}-${var.region2_loc}"
}

data "azurerm_virtual_network" "lz_spk_region2" {
  provider = azurerm.landingzone
  name                = "${var.lz_vnet_name_prefix}-${var.region2_loc}"
  resource_group_name = "${var.lz_spk_rg_prefix}-${var.region2_loc}-rg"
}

data "azurerm_private_dns_zone" "storage" {
  provider = azurerm.connectivity
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
}

data "azurerm_automation_account" "dsc" {
  provider = azurerm.management
  name                = "auto-core-${var.region1_loc}-${var.corp_prefix}"
  resource_group_name = var.svc_resource_group_name
}

module "shared_storage_account" {
  providers = {azurerm = azurerm.landingzone}
  source                          = "../../../../modules/storage/private"
  resource_group_name             = data.azurerm_virtual_network.lz_spk_region1.resource_group_name
  location                        = var.region1_loc
  storage_prefix                  = "corp"
  subnet_id                       = data.azurerm_subnet.lz_default_subnet_region1.id
  storage_zone_name               = "privatelink.blob.core.windows.net"
  storage_zone_id                 = data.azurerm_private_dns_zone.storage.id
}

module "shared_storage_account2" {
  providers = {azurerm = azurerm.landingzone}
  source                          = "../../../../modules/storage/private"
  resource_group_name             = data.azurerm_virtual_network.lz_spk_region2.resource_group_name
  location                        = data.azurerm_virtual_network.lz_spk_region2.location
  storage_prefix                  = "corp"
  subnet_id                       = data.azurerm_subnet.lz_default_subnet_region2.id
  storage_zone_name               = "privatelink.blob.core.windows.net"
  storage_zone_id                 = data.azurerm_private_dns_zone.storage.id
}

module "dev_vm" { 
    providers = {azurerm = azurerm.landingzone}
    source = "../../../../modules//virtual_machine"
    resource_group_name = data.azurerm_virtual_network.lz_spk_region1.resource_group_name
    location = data.azurerm_virtual_network.lz_spk_region1.location
    vm_name = var.vm_name
    vm_private_ip_addr = var.vm_private_ip_addr
    vm_size = var.vm_size
    vm_admin_username  = var.local_admin_username
    vm_admin_password  = var.local_admin_password
    subnet_id = data.azurerm_subnet.lz_default_subnet_region1.id
    storage_account_type = var.vm_storage_account_type
    data_disk_size_gb = var.vm_data_disk_size
    dsc_config                     = "devConfig.localhost"
    dsc_key                        = data.azurerm_automation_account.dsc.primary_key
    dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
    workspace_id  = data.azurerm_automation_account.dsc.id             
    workspace_key = data.azurerm_automation_account.dsc.primary_key
}
