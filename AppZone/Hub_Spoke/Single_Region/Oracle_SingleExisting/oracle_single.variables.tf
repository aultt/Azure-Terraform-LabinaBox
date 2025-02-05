variable "poc_subscription_id" {
    type        = string 
    description = "Subscription Id for POC subscription"
}
variable "vnet_name"{
    type =string
    default="vnet-lz-spk-eastus2"
}
variable "key_vault_name" {
  type=string
  default="kv-labiac-eastus2"
}
variable "location" {
    type=string
    default = "eastus2"
}
variable "keyvault_resource_group" {
    type = string
    default = "net-id-spk-eastus2-rg"
}
variable "lz_resource_group" {
    type = string
    default = "net-lz-spk-eastus2-rg"
}
variable "lz_vnet_name" {
    type = string
    default = "vnet-lz-spk-eastus2"
}
variable "vm_name" {
    type        = string
    default     = "oracledev01"
}
variable "enable_accelerated_networking" {
    type = string
    default = "false"
  
}
variable "vm_private_ip_addr" {
    type        = string 
    description = "Azure vm Host Address"
    default     = "10.1.1.15"
}
#Minumum of 8 GB of ram required.  Make sure VM supports number of disks you need to hub_region1_address_space
variable "vm_size" {
    type        = string 
    description = "Azure vm Host VM SKU"
    default     = "Standard_DS11_v2"
}

variable "asm_disk_size" {
    type        = string 
    description = "vmhost  data disk Size"
    default     = "64"
}
variable "asm_lun_start"{
    type = number
    description = "Starting Number for Lun assignment"
    default = "10"
}
variable "asm_disk_count" {
    type        = string 
    description = "Number of asm disks to be pooled"
    default     = "1"
}
variable "asm_disk_cache" {
    type        = string 
    description = "vmhost data disk caching"
    default     = "ReadWrite"
}
variable "asm_disk_prefix" {
    type        = string 
    description = "Used to dynamically name the Disk in the following format. vm_name-asm-disk-disknumber}"
    default     = "asm-disk"
}
variable "data_disk_size" {
    type        = string 
    description = "vmhost  data disk Size"
    default     = "512"
}
variable "data_lun_start"{
    type = number
    description = "Starting Number for Lun assignment"
    default = "20"
}
variable "data_disk_count" {
    type        = string 
    description = "Number of data disks to be pooled"
    default     = "2"
}
variable "data_disk_cache" {
    type        = string 
    description = "vmhost data disk caching"
    default     = "ReadOnly"
}
variable "data_disk_prefix" {
    type        = string 
    description = "Used to dynamically name the Disk in the following format. vm_name-asm-disk-disknumber}"
    default     = "data-disk"
}
variable "redo_disk_count" {
    type        = string 
    description = "Number of data disks to be pooled"
    default     = "2"
}
variable "redo_disk_size" {
    type        = string 
    description = "vmhost  data disk Size"
    default     = "128"
}
variable "redo_lun_start"{
    type = number
    description = "Starting Number for Lun assignment"
    default = "60"
}
variable "redo_disk_cache" {
    type        = string 
    description = "vmhost data disk caching"
    default     = "None"
}

variable "redo_disk_prefix" {
    type        = string 
    description = "Used to dynamically name the Disk in the following format. vm_name-asm-disk-disknumber}"
    default     = "redo-disk"
}

variable "storage_account_type" {
    type        = string 
    description = "vm host storage account type"
    default     = "StandardSSD_LRS"
}

variable "azurebastion_name" {
    type        = string
    default     = "corp-bastion-svc"
}

variable "bastion_addr_prefix" {
    type = string
    default = "10.1.250.0/24"
}

variable "admin_username" {
    type        = string 
    description = "Azure Admin Username"
    default = "azureadmin"
}
variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)

  default = {
    owner = "Oracle Database Workload"
  }
}

variable "swap_size" {
    type = string
    description = "Size in MB to set Swapsize to"
    default = "13435"
}

variable "oracle_database_name" {
  type = string
  description = "Oracle database name which will be created"
}