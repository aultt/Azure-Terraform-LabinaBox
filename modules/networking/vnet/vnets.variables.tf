
variable "resource_group_name" {}
variable "location" {}
variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type = map(string)

  default = {
    application = "networking"
  }
}
variable "vnet_name" {}
variable "address_space" {}
variable "default_subnet_prefixes"  {}
variable "dns_servers" {
  default = ["168.63.129.16"]
}
variable "route_table_add"{
  type = bool
  default = true
}
variable "route_table_id" {
  default = "none"
}

