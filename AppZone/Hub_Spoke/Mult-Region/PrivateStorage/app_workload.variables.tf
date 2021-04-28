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
