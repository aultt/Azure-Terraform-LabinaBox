variable "netA_name" {}
variable "netB_name" {}
variable "netA_id" {}
variable "netB_id" {}
variable "resource_group_nameA" {}
variable "resource_group_nameB" {}
variable "vnet_access" {
    default=true
}
variable "forward_traffic" {
    default=true
}
variable "gateway_transit" {
    default=false
}
variable "remote_gateways" {
    default = true
}