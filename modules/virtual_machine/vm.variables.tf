variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "vm_name" {}
#variable "vm_addr_prefix" {}
variable "vm_private_ip_addr" {}
variable "vm_size" {}
variable "storage_account_type" {}
variable "data_disk_size_gb" {}
variable "vm_admin_username" {}
variable "vm_admin_password" {}
variable "subnet_id" {}
variable "dsc_key" {}
variable "dsc_endpoint" {}
variable "dsc_config" {}
variable "workspace_id" {}
variable "workspace_key" {}
variable "dsc_mode" {default="applyAndAutoCorrect"}
variable "nic_forwarding" {
    default = "false"
}