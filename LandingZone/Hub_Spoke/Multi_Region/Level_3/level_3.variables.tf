variable "region1_loc" {
  default = "eastus"
}

variable "region2_loc" {
  default = "westus"
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
    default     = "prefix"
}

variable "management_subscription_id" {
    type        = string 
    description = "Subscription Id for Managemnet subscription"
    default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

variable "connectivity_subscription_id" {
    type        = string 
    description = "Subscription Id for Connectivity subscription"
    default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

variable "identity_subscription_id" {
    type        = string 
    description = "Subscription Id for Identity subscription"
    default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}


variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)

  default = {
    owner = "me"
  }
}

# DSC Variables
variable dsc_config {
  default = "blank"
}

variable dsc_mode {
  default = "applyAndMonitor"
}

# Azure Bastion module
variable "azurebastion_name" {
    type        = string
    default     = "corp-bastion-svc"
}
variable "azurebastion_addr_prefix" {
    type        = string 
    description = "Azure Bastion Address Prefix"
    default     = "10.1.250.0/24"
}

# Jump host module
variable "jump_host_name" {
    type        = string
    default     = "jumphostvm"
}
variable "jump_host_addr_prefix" {
    type        = string 
    description = "Azure Jump Host Address Prefix"
    default     = "10.1.251.0/24"  
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
    default     = "aedns001"
}
variable "dns1_addr_prefix" {
    type        = string 
    description = "Dc1 Address Prefix"
    default     = "10.3.3.0/24"  
}
variable "dns1_private_ip_addr" {
    type        = string 
    description = "DC2 Private IP Address"
    default     = "10.3.3.6"
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
# DC2 host module
variable "dc2_vm_name" {
    type        = string
    default     = "awdc001"
}
variable "dc2_addr_prefix" {
    type        = string 
    description = "Dc1 Address Prefix"
    default     = "10.4.3.0/24"  
}
variable "dc2_private_ip_addr" {
    type        = string 
    description = "DC2 Private IP Address"
    default     = "10.4.3.5"
}
variable "dc2_vm_size" {
    type        = string 
    description = "DC1 VM size"
    default     = "Standard_B2ms"
}
variable "dc2_data_disk_size" {
    type        = string 
    description = "Dc1 data disk Size"
    default     = "20"
}
variable "dc2_storage_account_type" {
    type        = string 
    description = "DC1 storage account type"
    default     = "Standard_LRS"
}
# Dns2 host module
variable "dns2_vm_name" {
    type        = string
    default     = "awdns001"
}
variable "dns2_addr_prefix" {
    type        = string 
    description = "Dc1 Address Prefix"
    default     = "10.4.3.0/24"  
}
variable "dns2_private_ip_addr" {
    type        = string 
    description = "DC2 Private IP Address"
    default     = "10.4.3.6"
}
variable "dns2_vm_size" {
    type        = string 
    description = "DC1 VM size"
    default     = "Standard_B2ms"
}
variable "dns2_data_disk_size" {
    type        = string 
    description = "Dc1 data disk Size"
    default     = "20"
}
variable "dns2_storage_account_type" {
    type        = string 
    description = "DC1 storage account type"
    default     = "Standard_LRS"
}
variable "local_admin_username" {
    type        = string 
    description = "Azure Admin Username"
    default = "azureadmin"
}
variable "local_admin_password" {
    sensitive   = true
    type        = string 
}
variable "svc_resource_group_name" {
    type        = string 
    description = "Shared Services Resource Group"
    default     = "svc-core-prod-rg"
}
variable "kv_region1_resource_group_name" {
    type        = string 
    description = "Keyvault Region1"
    default     = "net-id-spk-eastus-rg"
}
variable "kv_region1_name" {
    type        = string 
    description = "Keyvault Name for Region1"
    default     = "kv-eastus"
}
variable "location" {
    type = string
    default = "eastus"
} 

# LAW module

variable law_prefix {
    type       = string
    default    = "law"
}
variable "c" {
    type = string
    default = "infra"
}
variable "id_spk_region1_infra_subnet_name" {
    type = string
    default = "infra"
}
variable "id_spk_region1_infra_subnet_addr" {
    type = string
    default = "10.3.3.0/24"
}

variable "id_spk_region2_infra_subnet_name" {
    type = string
    default = "infra"
}

variable "id_spk_region2_infra_subnet_addr" {
    type = string
    default = "10.4.3.0/24"
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
