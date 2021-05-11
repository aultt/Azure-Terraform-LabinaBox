variable "resource_group_name" {}
variable "location" {}
variable "storage_prefix" {}
variable "account_tier" {
    default = "Standard"
}
variable "account_replication_type" {
    default = "LRS"
}
variable "subnet_id" {}
variable "storage_zone_name" {}
variable "storage_zone_id" {}