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
  name                = var.lz_vnet_name
  resource_group_name = var.lz_resource_group
}

data "azurerm_subnet" "lz_default_subnet_region1" {
  provider = azurerm.poc
  name                 = "default"
  resource_group_name  = var.lz_resource_group
  virtual_network_name = var.lz_vnet_name
}

data "azurerm_key_vault" "keyvault_region1" {
  name = var.key_vault_name
  resource_group_name =  var.keyvault_resource_group
}

resource "azurerm_resource_group" "oracle_resource_group" {
  name     = "oracle-${var.location}-rg"
  location = var.location
  tags     = var.tags
}

data "azurerm_key_vault_secret" "grid-pass" {
  name = "grid-password"
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}
output "grid_password" {
  value = "${data.azurerm_key_vault_secret.grid-pass.value}"
  sensitive = true
}

data "azurerm_key_vault_secret" "SASUrl" {
  name = "SASUrl"
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}
output "SASUrl" {
  value = "${data.azurerm_key_vault_secret.SASUrl.value}"
  sensitive = true
}

data "azurerm_key_vault_secret" "oracle-password" {
  name = "oracle-password"
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}
output "oracle-password" {
  value = "${data.azurerm_key_vault_secret.oracle-password.value}"
  sensitive = true
}

data "azurerm_key_vault_secret" "root-password" {
  name = "root-password"
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}
output "root-password" {
  value = "${data.azurerm_key_vault_secret.root-password.value}"
  sensitive = true
}

data "azurerm_key_vault_secret" "ora-sys-password" {
  name = "ora-sys-password"
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}
output "ora-sys-password" {
  value = "${data.azurerm_key_vault_secret.ora-sys-password.value}"
  sensitive = true
}

data "azurerm_key_vault_secret" "ora-system-password" {
  name = "ora-system-password"
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}
output "ora-system-password" {
  value = "${data.azurerm_key_vault_secret.ora-system-password.value}"
  sensitive = true
}

data "azurerm_key_vault_secret" "ora-monitor-password" {
  name = "ora-monitor-password"
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}
output "ora-monitor-password" {
  value = "${data.azurerm_key_vault_secret.ora-monitor-password.value}"
  sensitive = true
}

module "oracle_vm" { 
    providers = { azurerm = azurerm
      azurerm.poc = azurerm.poc }
    source = "../../../../modules/oracle_virtual_machine"
    resource_group_name = azurerm_resource_group.oracle_resource_group.name
    location = var.location
    vm_name = var.vm_name
    vm_private_ip_addr = var.vm_private_ip_addr
    vm_size = var.vm_size
    subnet_id = data.azurerm_subnet.lz_default_subnet_region1.id
    vm_admin_username = var.admin_username
    enable_accelerated_networking = var.enable_accelerated_networking
    grid_password = data.azurerm_key_vault_secret.grid-pass.value
    oracle_password = data.azurerm_key_vault_secret.oracle-password.value
    root_password = data.azurerm_key_vault_secret.root-password.value
    swap_size = var.swap_size
    grid_storage_url = data.azurerm_key_vault_secret.SASUrl.value
    ora_sys_password = data.azurerm_key_vault_secret.ora-sys-password.value
    ora_system_password = data.azurerm_key_vault_secret.ora-system-password.value
    ora_monitor_password = data.azurerm_key_vault_secret.ora-monitor-password.value
    oracle_database_name= var.oracle_database_name
}

module "data_disks"{
    source = "../../../../modules/managed_disk"
    resource_group_name = azurerm_resource_group.oracle_resource_group.name
    vm_name = module.oracle_vm.vm_name
    location = var.location
    storage_account_type = var.storage_account_type
    disk_prefix = var.data_disk_prefix
    disk_size_gb = var.data_disk_size
    disk_count = var.data_disk_count
    disk_cache_type = var.data_disk_cache
    vm_lun_start = var.data_lun_start
    depends_on = [
      module.oracle_vm,
    ]
}

module "redo_disks"{
    source = "../../../../modules/managed_disk"
    resource_group_name = azurerm_resource_group.oracle_resource_group.name
    vm_name = module.oracle_vm.vm_name
    location = var.location
    storage_account_type = var.storage_account_type
    disk_prefix = var.redo_disk_prefix
    disk_size_gb = var.redo_disk_size
    disk_count = var.redo_disk_count
    disk_cache_type = var.redo_disk_cache
    vm_lun_start = var.redo_lun_start
    depends_on = [
      module.oracle_vm,
    ]
}

module "asm_disks"{
    source = "../../../../modules/managed_disk"
    resource_group_name = azurerm_resource_group.oracle_resource_group.name
    vm_name = module.oracle_vm.vm_name
    location = var.location
    storage_account_type = var.storage_account_type
    disk_prefix = var.asm_disk_prefix
    disk_size_gb = var.asm_disk_size
    disk_count = var.asm_disk_count
    disk_cache_type = var.asm_disk_cache
    vm_lun_start = var.asm_lun_start
    depends_on = [
      module.oracle_vm,
    ]
}

resource "azurerm_key_vault_secret" "ora_key" {
  name         = "prikey-oracle"
  value        = module.oracle_vm.tls_private_key 
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}

#module "bastion_region1" {
#  providers = { azurerm = azurerm
#    azurerm.poc = azurerm.poc }
#  source = "../../../../modules/azure_bastion"
#  resource_group_name  = azurerm_resource_group.oracle_resource_group.name
#  location = var.location
#  azurebastion_name = var.azurebastion_name
#  azurebastion_vnet_name = module.vnet.vnet_name
#  azurebastion_addr_prefix = var.bastion_addr_prefix
#}


