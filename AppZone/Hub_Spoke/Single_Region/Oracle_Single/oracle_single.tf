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
    alias = "landingzone"
    subscription_id = var.landingzone_subscription_id
}
provider "azurerm" {
    features {} 
    alias = "identity"
    subscription_id = var.identity_subscription_id
}

data "azurerm_virtual_network" "lz_spk_region1" {
  provider = azurerm.landingzone
  name                = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_key_vault" "Region1_vault" {
  provider = azurerm.identity
  resource_group_name = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
  name = "kv-${var.corp_prefix}-${var.region1_loc}" 
}

data "azurerm_subnet" "lz_default_subnet_region1" {
  provider = azurerm.landingzone
  name                 = "default"
  resource_group_name  = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
}

resource "azurerm_resource_group" "oracle_region1" {
  provider = azurerm.landingzone
  name     = "oracle-${var.region1_loc}-rg"
  location = var.region1_loc
  tags     = var.tags
}

module "oracle_vm" { 
    providers = {azurerm = azurerm.landingzone}
    source = "../../../../modules/oracle_virtual_machine"
    resource_group_name = azurerm_resource_group.oracle_region1.name
    location = var.region1_loc
    vm_name = var.vm_name
    vm_private_ip_addr = var.vm_private_ip_addr
    vm_size = var.vm_size
    subnet_id = data.azurerm_subnet.lz_default_subnet_region1.id
    vm_admin_username = var.admin_username
    enable_accelerated_networking = var.enable_accelerated_networking
}

module "data_disks"{
    providers = {azurerm = azurerm.landingzone}
    source = "../../../../modules/managed_disk"
    resource_group_name = azurerm_resource_group.oracle_region1.name
    vm_name = module.oracle_vm.vm_name
    location = var.region1_loc
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
    providers = {azurerm = azurerm.landingzone}
    source = "../../../../modules/managed_disk"
    resource_group_name = azurerm_resource_group.oracle_region1.name
    vm_name = module.oracle_vm.vm_name
    location = var.region1_loc
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
    providers = {azurerm = azurerm.landingzone}
    source = "../../../../modules/managed_disk"
    resource_group_name = azurerm_resource_group.oracle_region1.name
    vm_name = module.oracle_vm.vm_name
    location = var.region1_loc
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
  provider = azurerm.identity
  name         = "prikey-oracle-single2"
  value        = module.oracle_vm.tls_private_key 
  key_vault_id = data.azurerm_key_vault.Region1_vault.id
}

variable "oracle_config_path" {
  type = string
  default = "oracle.pem"
}

locals {
  oracle_config = <<-EOT
    ${module.oracle_vm.tls_private_key}
  EOT
}

resource "local_file" "oracle_key" {
  filename = var.oracle_config_path
  content  = local.oracle_config
  file_permission = "0500"
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i '${var.vm_private_ip_addr}', -u '${var.admin_username}' --private-key '${var.oracle_config_path}' ansible/Configure-ASM-server.yml -e gridpass='${var.grid_password}' -e oraclepass='${var.oracle_password}' -e rootpass='${var.root_password}' -e swapsize='${var.swap_size}' -e gridurl='${var.grid_storage_url}' -e syspass='${var.ora_sys_password}' -e systempass='${var.ora_system_password}' -e monitorpass='${var.ora_monitor_password}' -e dbname='${var.oracle_database_name}'"  
  }
  depends_on = [
    module.oracle_vm,module.asm_disks,module.redo_disks,module.data_disks,
  ]
}

