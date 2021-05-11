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

variable "gateway_ip_address" {
    type = string
    description = "Local Network Gateway Address"
    default = "00.00.000.0" 
}

variable "Vpn_shared_key" {
    sensitive   = true
    type = string
    description = "Shared Key for VPN Connection"
}

variable "corp_prefix" {
    type        = string 
    description = "Corp name Prefix"
    default     = "prefix"
}

variable "domain_name" {
  default = "domain.net"
}

variable "domain_ip" {
  default = "192.168.100.5"
}

variable "region1_loc" {
  default = "eastus"
}
#AutomationAccount must be in a supported region for linking 
#https://docs.microsoft.com/en-us/azure/automation/how-to/region-mappings
variable "automation_loc" {
  default = "eastus2"
}

variable "region2_loc" {
  default = "westus"
}

variable "local_network_gateway_prefix" {
    type = list
    description = "Local Network Gateway Address Space"
    default = ["192.168.100.0/24","192.168.101.0/24"]
}

variable "local_network_gateway_name" {
    type = string
    description = "Local Network Gateway Name"
    default = "My-Home"
}
variable "gateway_pip_name" {
    type = string
    description = "Virtual Network Gateway Public IP Name"
    default = "mynet-vpg-ip"
}
variable "gateway_name" {
    type = string
    description = "Virtual Network Gateway Name"
    default = "mynet-vpg"
}
variable "s2s_connection_name" {
    type = string
    description = "Site to Site Connetion Name"
    default = "mynet-s2s-conn"
}
variable "svc_resource_group_name" {
    type        = string 
    description = "Shared Services Resource Group"
    default     = "svc-core-prod-rg"
}

# LAW module
variable law_prefix {
    type       = string
    default    = "law"
}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)

  default = {
    owner = "ault"
  }
}

# DSC Variables
variable dsc_config {
  default = "blank"
}

variable dsc_mode {
  default = "applyAndMonitor"
}


variable "domain_NetbiosName" {
  default = "corp"
}
variable "domain_admin_username" {
  type        = string 
}
variable "domain_admin_password" {
  sensitive   = true
  type        = string 
}
# Azure Bastion module
variable "azurebastion_name" {
    type        = string
    default     = "corp-bastion-svc"
}
variable "azurebastion_addr_prefix" {
    type        = string 
    description = "Azure Bastion Address Prefix"
    default     = "10.1.250.0/24"
}

# Jump host module
variable "jump_host_name" {
    type        = string
    default     = "jumphostvm"
}
variable "jump_host_addr_prefix" {
    type        = string 
    description = "Azure Jump Host Address Prefix"
    default     = "10.1.251.0/24"  
}

variable "jump_host_subnet_name" {
    type        = string 
    default = "jumphost-subnet"
}

variable "jump_host_admin_username" {
    type        = string 
    description = "Azure Admin Username"
}
variable "jump_host_password" {
    sensitive   = true
    type        = string 
}

variable "gateway_address_prefix" {
    type = string
    description = "Local Network Gateway Address Space"
    default = "10.1.252.0/24"
}
variable "region2_gateway_address_prefix" {
    type = string
    description = "Local Network Gateway Address Space"
    default = "10.2.252.0/24"
}

# Dns2 host module
variable "dns2_vm_name" {
    type        = string
    default     = "awdns001"
}
# Dns2 host module
variable "dns1_vm_name" {
    type        = string
    default     = "aedns001"
}

variable "hub_vnet_name_prefix"{
    type = string
    default = "vnet-hub"
}
variable "id_spk_vnet_name_prefix"{
    type = string
    default = "vnet-id-spk"
}

variable "hub_rg_prefix" {
    type = string
    default =  "net-core-hub"
}

variable "hub_region1_address_space" {
    type = string
    default =  "10.1.0.0/16"
}

variable "hub_region1_default_subnet" {
    type = string
    default =  "10.1.1.0/24"
}

variable "hub_region2_address_space" {
    type = string
    default =  "10.2.0.0/16"
}

variable "hub_region2_default_subnet" {
    type = string
    default =  "10.2.1.0/24"
}

variable "id_spk_rg_prefix" {
    type = string
    default =  "net-id-spk"
}

variable "id_spk_region1_address_space" {
    type = string
    default =  "10.3.0.0/16"
}

variable "id_spk_region1_default_subnet" {
    type = string
    default = "10.3.1.0/24"
}

variable "id_spk_region1_shared_subnet_name" {
    type = string
    default = "shared"
}

variable "id_spk_region1_shared_subnet_addr" {
    type = string
    default = "10.3.2.0/24"
}

variable "id_spk_region2_address_space" {
    type = string
    default =  "10.4.0.0/16"
}

variable "id_spk_region2_default_subnet" {
    type = string
    default = "10.4.1.0/24"
}

variable "id_spk_region2_shared_subnet_name" {
    type = string
    default = "shared"
}

variable "id_spk_region2_shared_subnet_addr" {
    type = string
    default = "10.4.2.0/24"
}

variable "bastion_addr_prefix" {
    type = string
    default = "10.1.250.0/24"
}

variable "dc1_private_ip_addr" {
    type        = string 
    description = "DC1 Private IP Address"
    default     = "10.3.3.5"
}
variable "dc2_private_ip_addr" {
    type        = string 
    description = "DC2 Private IP Address"
    default     = "10.4.3.5"
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
