# Azure provider version 
#Prior to running DSC Configurations must be compiled in the Automation account.
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
data "azurerm_subnet" "hub_default_subnet_region1" {
  provider = azurerm.connectivity
  name                 = "default"
  resource_group_name  = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
}
data "azurerm_subnet" "hub_default_subnet_region2" {
  provider = azurerm.connectivity
  name                 = "default"
  resource_group_name  = "${var.hub_rg_prefix}-${var.region2_loc}-rg"
  virtual_network_name = "${var.hub_vnet_name_prefix}-${var.region2_loc}"
}
data "azurerm_virtual_network" "id_spk_region1" {
  provider = azurerm.identity
  name                = "${var.id_spk_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_virtual_network" "id_spk_region2" {
  provider = azurerm.identity
  name                = "${var.id_spk_vnet_name_prefix}-${var.region2_loc}"
  resource_group_name = "${var.id_spk_rg_prefix}-${var.region2_loc}-rg"
}

data "azurerm_subnet" "hub_shared_subnet" {
  provider = azurerm.connectivity
  name                 = var.jump_host_subnet_name
  resource_group_name  = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
}

data "azurerm_subnet" "id_spk_shared_subnet_Region1" {
  provider = azurerm.identity
  name                 = var.id_spk_region1_shared_subnet_name
  resource_group_name  = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.id_spk_vnet_name_prefix}-${var.region1_loc}"
}

data "azurerm_automation_account" "dsc" {
  provider = azurerm.management
  name                = "auto-core-${var.location}-${var.corp_prefix}"
  resource_group_name = var.svc_resource_group_name
}

data "azurerm_log_analytics_workspace" "law" {
  provider = azurerm.management
  name = "${var.law_prefix}-core-${var.corp_prefix}-001"
  resource_group_name = var.svc_resource_group_name
}

data "azurerm_route_table" "Identity_Region1" {
  provider = azurerm.Identity
  name = "RT-${var.id_spk_rg_prefix}-${var.region1_loc}" 
  resource_group_name = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_route_table" "Identity_Region2" {
  provider = azurerm.Identity
  name = "RT-${var.id_spk_rg_prefix}-${var.region2_loc}" 
  resource_group_name = "${var.id_spk_rg_prefix}-${var.region2_loc}-rg"
}

module "id_spk_region1_infra_subnet_Region1"{
  providers = {azurerm = azurerm.identity}
  source = "../../../../modules/networking/subnet"
  resource_group_name = data.azurerm_virtual_network.id_spk_region1.resource_group_name
  vnet_name = data.azurerm_virtual_network.id_spk_region1.name
  location = var.region1_loc
  subnet_name = var.id_spk_region1_infra_subnet_name
  subnet_prefixes = [var.id_spk_region1_infra_subnet_addr]
}

resource "azurerm_subnet_route_table_association" "infra_Region1" {
  provider = azurerm.identity
  subnet_id      = module.id_spk_region1_infra_subnet_Region1.subnet_id
  route_table_id = data.azurerm_route_table.Identity_Region1.id
}

module "id_spk_region2_infra_subnet_Region2"{
  providers = {azurerm = azurerm.identity}
  source = "../../../../modules/networking/subnet"
  resource_group_name = data.azurerm_virtual_network.id_spk_region2.resource_group_name
  vnet_name = data.azurerm_virtual_network.id_spk_region2.name
  location = var.region2_loc
  subnet_name = var.id_spk_region2_infra_subnet_name
  subnet_prefixes = [var.id_spk_region2_infra_subnet_addr]
}

resource "azurerm_subnet_route_table_association" "infra_Region2" {
  provider = azurerm.identity
  subnet_id      = module.id_spk_region1_infra_subnet_Region2.subnet_id
  route_table_id = data.azurerm_route_table.Identity_Region2.id
}

module "dev_vm" { 
    providers = {azurerm = azurerm.connectivity}
    source = "../../../../modules//virtual_machine"
    resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
    location = data.azurerm_virtual_network.hub_region1.location
    vm_name = var.jump_host_name
    vm_private_ip_addr = var.jump_host_private_ip_addr
    vm_size = var.jump_host_vm_size
    vm_admin_username  = var.local_admin_username
    vm_admin_password  = var.local_admin_password
    subnet_id = data.azurerm_subnet.hub_shared_subnet.id
    storage_account_type = var.jump_host_storage_account_type
    data_disk_size_gb = var.jump_host_data_disk_size
    dsc_config                     = "devConfig.localhost"
    dsc_key                        = data.azurerm_automation_account.dsc.primary_key
    dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
    workspace_id  = data.azurerm_automation_account.dsc.id             
    workspace_key = data.azurerm_automation_account.dsc.primary_key
}

module "DC1_vm" { 
    providers = {azurerm = azurerm.identity}
    source = "../../../../modules//virtual_machine"
    resource_group_name = data.azurerm_virtual_network.id_spk_region1.resource_group_name
    location = data.azurerm_virtual_network.id_spk_region1.location
    vm_name = var.dc1_vm_name
    vm_private_ip_addr = var.dc1_private_ip_addr
    vm_size = var.dc1_vm_size
    vm_admin_username  = var.local_admin_username
    vm_admin_password  = var.local_admin_password
    subnet_id = module.id_spk_region1_infra_subnet_Region1.subnet_id
    storage_account_type = var.dc1_storage_account_type
    data_disk_size_gb = var.dc1_data_disk_size
    dsc_config                     = "DC2Config.localhost"
    dsc_key                        = data.azurerm_automation_account.dsc.primary_key
    dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
    workspace_id  = data.azurerm_automation_account.dsc.id             
    workspace_key = data.azurerm_automation_account.dsc.primary_key
}
module "DC2_vm" { 
    providers = {azurerm = azurerm.identity}
    source = "../../../../modules//virtual_machine"
    resource_group_name = data.azurerm_virtual_network.id_spk_region2.resource_group_name
    location = data.azurerm_virtual_network.id_spk_region2.location
    vm_name = var.dc2_vm_name
    vm_private_ip_addr = var.dc2_private_ip_addr
    vm_size = var.dc2_vm_size
    vm_admin_username  = var.local_admin_username
    vm_admin_password  = var.local_admin_password
    subnet_id = module.id_spk_region2_infra_subnet_Region2.subnet_id
    storage_account_type = var.dc2_storage_account_type
    data_disk_size_gb = var.dc2_data_disk_size
    dsc_config                     = "DC2Config.localhost"
    dsc_key                        = data.azurerm_automation_account.dsc.primary_key
    dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
    workspace_id  = data.azurerm_automation_account.dsc.id             
    workspace_key = data.azurerm_automation_account.dsc.primary_key
}

module "Dns1_vm" { 
    providers = {azurerm = azurerm.connectivity}
    source = "../../../../modules//virtual_machine"
    resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
    location = data.azurerm_virtual_network.hub_region1.location
    vm_name = var.dns1_vm_name
    vm_private_ip_addr = var.dns1_private_ip_addr
    vm_size = var.dns1_vm_size
    vm_admin_username  = var.local_admin_username
    vm_admin_password  = var.local_admin_password
    subnet_id = data.azurerm_subnet.hub_default_subnet_region1.id
    storage_account_type = var.dns1_storage_account_type
    data_disk_size_gb = var.dns1_data_disk_size
    nic_forwarding = "true"
    dsc_config                     = "Dns1Config.localhost"
    dsc_key                        = data.azurerm_automation_account.dsc.primary_key
    dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
    workspace_id  = data.azurerm_automation_account.dsc.id             
    workspace_key = data.azurerm_automation_account.dsc.primary_key
}
module "Dns2_vm" { 
    providers = {azurerm = azurerm.connectivity}
    source = "../../../../modules//virtual_machine"
    resource_group_name = data.azurerm_virtual_network.hub_region2.resource_group_name
    location = data.azurerm_virtual_network.hub_region2.location
    vm_name = var.dns2_vm_name
    vm_private_ip_addr = var.dns2_private_ip_addr
    vm_size = var.dns2_vm_size
    vm_admin_username  = var.local_admin_username
    vm_admin_password  = var.local_admin_password
    subnet_id = data.azurerm_subnet.hub_default_subnet_region2.id
    storage_account_type = var.dns2_storage_account_type
    data_disk_size_gb = var.dns2_data_disk_size
    nic_forwarding = "true"
    dsc_config                     = "Dns2Config.localhost"
    dsc_key                        = data.azurerm_automation_account.dsc.primary_key
    dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
    workspace_id  = data.azurerm_automation_account.dsc.id             
    workspace_key = data.azurerm_automation_account.dsc.primary_key
}
