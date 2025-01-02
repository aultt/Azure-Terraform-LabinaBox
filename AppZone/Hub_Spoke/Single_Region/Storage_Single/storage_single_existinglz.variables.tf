variable "region1_loc" {
  type = string
  default = "eastus2"
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

variable "poc_subscription_id" {
    type        = string 
    description = "Subscription Id for POC subscription"
}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)
  default = {owner = "ault"}
}

variable "id_spk_region1_infra_subnet_name" {
    type = string
    default = "infra"
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

variable "lz_spk_rg_prefix" {
    type = string
    default =  "net-lz-spk"
}
variable "lz_vnet_name_prefix" {
    type        = string 
    description = "Landingzone vnet name prefix.  Appended with Region"
    default = "vnet-lz-spk"
}

variable "hub_rg_prefix" {
    type = string
    default =  "net-core-hub"
}

variable "hub_vnet_name_prefix"{
    type = string
    default = "vnet-hub"
}