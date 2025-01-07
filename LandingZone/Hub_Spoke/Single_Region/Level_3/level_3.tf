terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.52"
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
data "azurerm_virtual_network" "hub_region1" {
  provider = azurerm.poc
  name                = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_key_vault" "keyvault_region1" {
  name = var.key_vault_name
  resource_group_name =  var.keyvault_resource_group
}

data "azurerm_subnet" "hub_default_subnet_region1" {
  provider = azurerm.poc
  name                 = "default"
  resource_group_name  = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
}
data "azurerm_subnet" "id_spk_region1_infra_subnet_Region1" {
  provider = azurerm.poc
  name                 = var.id_spk_region1_infra_subnet_name
  resource_group_name  = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.id_spk_vnet_name_prefix}-${var.region1_loc}"
}
data "azurerm_virtual_network" "id_spk_region1" {
  provider = azurerm.poc
  name                = "${var.id_spk_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_subnet" "jumphost_subnet_Region1" {
  provider = azurerm.poc
  name                 = var.jump_host_subnet_name
  resource_group_name  = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
}
data "azurerm_automation_account" "dsc" {
  provider = azurerm.poc
  name                = "auto-core-${var.region1_loc}-${var.corp_prefix}"
  resource_group_name = "${var.svc_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_key_vault_secret" "local-admin-password" {
  name = "local-admin-password"
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}
output "local-admin-password" {
  value = "${data.azurerm_key_vault_secret.local-admin-password.value}"
  sensitive = true
}

##module "DC1_vm" { 
##    providers = { azurerm = azurerm
##      azurerm.poc = azurerm.poc }
##    source = "../../../../modules//virtual_machine"
##    #count = var.deploy_domain ? 1 : 0
##    resource_group_name = data.azurerm_virtual_network.id_spk_region1.resource_group_name
##    location = data.azurerm_virtual_network.id_spk_region1.location
##    vm_name = var.dc1_vm_name
##    vm_private_ip_addr = var.dc1_private_ip_addr
##    vm_size = var.dc1_vm_size
##    vm_admin_username  = var.local_admin_username
##    vm_admin_password  = data.azurerm_key_vault_secret.local-admin-password.value
##    subnet_id = data.azurerm_subnet.id_spk_region1_infra_subnet_Region1.id
##    storage_account_type = var.dc1_storage_account_type
##    data_disk_size_gb = var.dc1_data_disk_size
##    dsc_config = "NewDCConfig.localhost"
##    dsc_key = data.azurerm_automation_account.dsc.primary_key
##    dsc_endpoint = data.azurerm_automation_account.dsc.endpoint
##    workspace_id  = data.azurerm_automation_account.dsc.id             
##    workspace_key = data.azurerm_automation_account.dsc.primary_key
##    offer = "WindowsServer"
##    publisher = "MicrosoftWindowsServer"
##    sku = "2019-Datacenter"
##}
##
##module "Dns1_vm" { 
##    providers = { azurerm = azurerm
##      azurerm.poc = azurerm.poc }
##    source = "../../../../modules/virtual_machine"
##    #count = var.deploy_domain ? 1 : 0
##    resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
##    location = data.azurerm_virtual_network.hub_region1.location
##    vm_name = var.dns1_vm_name
##    vm_private_ip_addr = var.dns1_private_ip_addr
##    vm_size = var.dns1_vm_size
##    vm_admin_username  = var.local_admin_username
##    vm_admin_password  = data.azurerm_key_vault_secret.local-admin-password.value
##    subnet_id = data.azurerm_subnet.hub_default_subnet_region1.id
##    storage_account_type = var.dns1_storage_account_type
##    data_disk_size_gb = var.dns1_data_disk_size
##    nic_forwarding = "true"
##    dsc_config = var.deploy_domain ? "Dns1Config.localhost" : "NVA1Config.localhost"
##    dsc_key = data.azurerm_automation_account.dsc.primary_key
##    dsc_endpoint = data.azurerm_automation_account.dsc.endpoint
##    workspace_id  = data.azurerm_automation_account.dsc.id             
##    workspace_key = data.azurerm_automation_account.dsc.primary_key
##    offer = "WindowsServer"
##    publisher = "MicrosoftWindowsServer"
##    sku = "2019-Datacenter"
##    #depends_on = [ module.DC1_vm ]
##}

module "dev_vm" { 
    providers = { azurerm = azurerm
      azurerm.poc = azurerm.poc }
    source = "../../../../modules/virtual_machine"
    resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
    location = data.azurerm_virtual_network.hub_region1.location
    vm_name = "aedev001"
    vm_private_ip_addr = var.jump_host_private_ip_addr
    vm_size = var.jump_host_vm_size
    vm_admin_username  = var.local_admin_username
    vm_admin_password  = data.azurerm_key_vault_secret.local-admin-password.value
    subnet_id = data.azurerm_subnet.jumphost_subnet_Region1.id
    storage_account_type = var.jump_host_storage_account_type
    data_disk_size_gb = var.jump_host_data_disk_size
    dsc_config                     = "devConfigNoDomain.localhost"
    dsc_key                        = data.azurerm_automation_account.dsc.primary_key
    dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
    workspace_id  = data.azurerm_automation_account.dsc.id             
    workspace_key = data.azurerm_automation_account.dsc.primary_key
    publisher = "MicrosoftWindowsDesktop"
    offer = "Windows-11"
    sku = "win11-24h2-pro"
    #depends_on = [module.Dns1_vm]
}