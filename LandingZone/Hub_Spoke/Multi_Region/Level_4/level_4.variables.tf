variable "region1_loc" {
  default = "eastus"
}

variable "region2_loc" {
  default = "westus"
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

variable "dc_region1_ip" {
    type        = string 
    description = "Ip address of Domain controller for Region1"
    default = "10.3.3.5"
}
variable "dns_region1_ip" {
    type        = string 
    description = "Ip address of Domain controller for Region2"
    default = "10.1.1.5"
}
variable "dc_region2_ip" {
    type        = string 
    description = "Ip address of Domain controller for Region1"
    default = "10.4.3.5"
}
variable "dns_region2_ip" {
    type        = string 
    description = "Ip address of Domain controller for Region2"
    default = "10.1.1.5"
}

variable "lz_address_space_region1" {
    type        = string 
    description = "LandingZone Address Space"
    default = "10.5.0.0/16"
}
variable "lz_dsubnet_address_space_region1" {
    type        = string 
    description = "LandingZone Address Space"
    default = "10.5.1.0/24"
}
variable "lz_address_space_region2" {
    type        = string 
    description = "LandingZone Address Space"
    default = "10.6.0.0/16"
}
variable "lz_dsubnet_address_space_region2" {
    type        = string 
    description = "LandingZone Address Space"
    default = "10.6.1.0/24"
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

#Sandbox Variables
variable "sb_spk_rg_prefix" {
    type = string
    default =  "net-sb-spk"
}
variable "sb_address_space_region1" {
    type        = string 
    description = "LandingZone Address Space"
    default = "10.7.0.0/16"
}
variable "sb_dsubnet_address_space_region1" {
    type        = string 
    description = "LandingZone Address Space"
    default = "10.7.1.0/24"
}
variable "sb_address_space_region2" {
    type        = string 
    description = "LandingZone Address Space"
    default = "10.8.0.0/16"
}
variable "sb_dsubnet_address_space_region2" {
    type        = string 
    description = "LandingZone Address Space"
    default = "10.8.1.0/24"
}
variable "sb_vnet_name_prefix" {
    type        = string 
    description = "Landingzone vnet name prefix.  Appended with Region"
    default = "vnet-sb-spk"
}

# ID Spk 
variable "id_spk_vnet_name_prefix"{
    type = string
    default = "vnet-id-spk"
}
variable "id_spk_rg_prefix" {
    type = string
    default =  "net-id-spk"
}
variable "dns_nva2_private_ip_addr" {
    type        = string 
    description = "DC2 Private IP Address"
    default     = "10.2.1.5"
}
variable "dns_nva1_private_ip_addr" {
    type        = string 
    description = "DC1 Private IP Address"
    default     = "10.1.1.5"
}
