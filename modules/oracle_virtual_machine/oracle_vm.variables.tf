variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "vm_name" {}
variable "vm_private_ip_addr" {}
variable "vm_size" {}
variable "os_storage_account_type" { default ="Standard_LRS"}
variable "vm_admin_username" {}
variable "subnet_id" {}
variable "nic_forwarding" {
    default = "false"
}
variable "vm_publisher" { default =  "Oracle"}
variable "vm_offer"     { default = "oracle-database-19-3"}
variable "vm_sku"       { default = "oracle-database-19-0904"} 
variable "vm_version"   { default =  "latest"}
variable "enable_accelerated_networking" {}
variable "grid_password" {}
variable "oracle_password" {}
variable "root_password" {}
variable "swap_size" {}
variable "grid_storage_url" {}
variable "ora_sys_password" {}
variable "ora_system_password" {}
variable "ora_monitor_password" {}
variable "oracle_database_name" {}