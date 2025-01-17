variable "resource_group_name" {
    type = string
    default = "data-eastus2-rg"
}
variable "location" {
    type = string
    default = "eastus2"
}
variable "name" {
    type = string
    default = "tamz-powerbi"
}

variable "poc_subscription_id" {
    type = string
    default = "e8099715-ae50-49df-a170-610ff52793e2"
}

variable "dns_zone_group" {
    type = string
    default = "fabric_dns_zone_group"
}

variable "hub_resource_group" {
    type = string
    default = "net-core-hub-eastus2-rg"
}
variable "lz_network_name" {
    type = string
    default = "vnet-lz-spk-eastus2"
}
variable "lz_network_rg" {
    type = string
    default = "net-lz-spk-eastus2-rg"
}
variable "lz_subnet_name" {
    type = string
    default = "default"
}