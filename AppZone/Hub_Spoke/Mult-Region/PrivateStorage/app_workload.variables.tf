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
variable "landingzone_subscription_id" {
    type        = string 
    description = "Subscription Id for LandingZone subscription"
    default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

variable "sandbox_subscription_id" {
    type        = string 
    description = "Subscription Id for SandBox subscription"
    default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

variable "corp_prefix" {
    type        = string 
    description = "Corp name Prefix"
    default     = "prefix"
}

variable "region1_loc" {
  default = "eastus"
}

variable "region2_loc" {
  default = "westus"
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

variable "lz_vnet_name_prefix" {
    type        = string 
    description = "Landingzone vnet name prefix.  Appended with Region"
    default = "vnet-lz-spk"
}

variable "lz_spk_rg_prefix" {
    type = string
    default =  "net-lz-spk"
}
# Dev Vm
variable "vm_name" {
    type        = string
    default     = "corplzdev001"
}
variable "vm_private_ip_addr" {
    type        = string 
    description = "Azure vm Host Address"
    default     = "10.5.1.10"
}
variable "vm_size" {
    type        = string 
    description = "Azure vm Host VM SKU"
    default     = "Standard_B2ms"
}
variable "vm_data_disk_size" {
    type        = string 
    description = "vmhost  data disk Size"
    default     = "20"
}
variable "vm_storage_account_type" {
    type        = string 
    description = "vm host storage account type"
    default     = "Standard_LRS"
}
variable "vm_subnet_name" {
    type        = string 
    default = "default"
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