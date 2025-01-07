variable "region1_loc" {
  type = string
  default = "eastus2"
}
variable "key_vault_name" {
  type=string
  default="kv-TAMZ-eastus2"
}

variable "keyvault_resource_group" {
    type = string
    default = "net-id-spk-eastus2-rg"
}
variable "region1_name" {
  default = "hub1"
}

variable "region2_name" {
  default = "hub2"
}
variable "corp_prefix" {
    type        = string 
    description = "Corp name Prefix"
}
variable "hybrid_deployment" {
    type = bool
    description = "Is this a Hybrid Deployment or Cloud Only"
    default = false
}

variable "deploy_domain" {
    type = bool
    description = "Deploy domain controller?"
    default = true
}

variable "poc_subscription_id" {
    type        = string 
    description = "Subscription Id for POC subscription"
}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)
  default = {owner = "ault"}
}

# DSC Variables
variable dsc_config {
  default = "blank"
}

variable dsc_mode {
  default = "applyAndMonitor"
}

# Jump host module
variable "jump_host_name" {
    type        = string
    default     = "jumphostvm"
}

variable "jump_host_private_ip_addr" {
    type        = string 
    description = "Azure Jump Host Address"
    default     = "10.1.251.5"
}
variable "jump_host_vm_size" {
    type        = string 
    description = "Azure Jump Host VM SKU"
    default     = "Standard_B2ms"
}
variable "jump_host_data_disk_size" {
    type        = string 
    description = "jumphost  data disk Size"
    default     = "20"
}
variable "jump_host_storage_account_type" {
    type        = string 
    description = "jump host storage account type"
    default     = "Standard_LRS"
}
variable "jump_host_subnet_name" {
    type        = string 
    default = "jumphost-subnet"
}
# DC1 host module
variable "dc1_vm_name" {
    type        = string
    default     = "aedc001"
}
variable "dc1_addr_prefix" {
    type        = string 
    description = "Dc1 Address Prefix"
    default     = "10.3.3.0/24"  
}
variable "dc1_private_ip_addr" {
    type        = string 
    description = "DC2 Private IP Address"
    default     = "10.3.3.5"
}
variable "dc1_vm_size" {
    type        = string 
    description = "DC1 VM size"
    default     = "Standard_B2ms"
}
variable "dc1_data_disk_size" {
    type        = string 
    description = "Dc1 data disk Size"
    default     = "20"
}
variable "dc1_storage_account_type" {
    type        = string 
    description = "DC1 storage account type"
    default     = "Standard_LRS"
}
# Dns1 host module
variable "dns1_vm_name" {
    type        = string
    default     = "aednsnva1"
}
variable "dns1_addr_prefix" {
    type        = string 
    description = "Dc1 Address Prefix"
    default     = "10.1.1.0/24"  
}
variable "dns1_private_ip_addr" {
    type        = string 
    description = "DC2 Private IP Address"
    default     = "10.1.1.5"
}
variable "dns1_vm_size" {
    type        = string 
    description = "DC1 VM size"
    default     = "Standard_B2ms"
}
variable "dns1_data_disk_size" {
    type        = string 
    description = "Dc1 data disk Size"
    default     = "20"
}
variable "dns1_storage_account_type" {
    type        = string 
    description = "DC1 storage account type"
    default     = "Standard_LRS"
}
variable "local_admin_username" {
    type        = string 
    description = "Azure Admin Username"
    default = "azureadmin"
}
#variable "local_admin_password" {
#    sensitive   = true
#    type        = string 
#}
variable "svc_rg_prefix" {
    type        = string 
    description = "Shared Services Resource Group"
    default     = "svc-core"
}

variable "id_spk_region1_infra_subnet_name" {
    type = string
    default = "infra"
}
variable "id_spk_region1_infra_subnet_addr" {
    type = string
    default = "10.3.3.0/24"
}

variable "hub_rg_prefix" {
    type = string
    default =  "net-core-hub"
}

variable "hub_vnet_name_prefix"{
    type = string
    default = "vnet-hub"
}

variable "id_spk_vnet_name_prefix"{
    type = string
    default = "vnet-id-spk"
}
variable "id_spk_rg_prefix" {
    type = string
    default =  "net-id-spk"
}
variable "id_spk_region1_shared_subnet_name" {
    type = string
    default = "shared"
}

#NVA VMs
variable "nvaregion1_name" {
    type        = string
    default     = "aenva001"
}
variable "nvaregion1_private_ip_addr" {
    type        = string 
    description = "Azure vm Host Address"
    default     = "10.1.1.5"
}
