variable "poc_subscription_id" {
    type        = string 
    description = "Subscription Id for POC subscription"
}

variable "hybrid_deployment" {
    type = bool
    description = "Is this a Hybrid Deployment or Cloud Only"
    default = false
}
variable "deploy_DC" {
    type = bool
    description = "Is this a Hybrid Deployment or Cloud Only"
    default = false
}
variable "gateway_ip_address" {
    type = string
    description = "Local Network Gateway Address"
}

variable "Vpn_shared_key" {
    type = string
    description = "VPN SharedKey to connect"
}

variable "corp_prefix" {
    type        = string 
    description = "Corp name Prefix"
}

variable "domain_name" {
  type =string
  description = "Windows Domain Name"
}

variable "region1_loc" {
  type = string
  default = "eastus2"
}
#AutomationAccount must be in a supported region for linking 
#https://docs.microsoft.com/en-us/azure/automation/how-to/region-mappings
variable "automation_loc" {
   type = string
   default = "eastus2"
}

variable "svc_rg_prefix" {
    type        = string 
    description = "Shared Services Resource Group"
    default     = "svc-core"
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
    owner = "owner"
  }
}

# DSC Variables
variable dsc_config {
  default = "blank"
}

variable dsc_mode {
  default = "applyAndMonitor"
}

variable "domain_ip" {
  type = string
  description = "On-Prem domain ip address for DNS resolution"
}
variable "domain_NetbiosName" {
    type = string
    description = "On-prem Domain NetbiosName"
}
variable "domain_admin_username" {
    type = string
    description = "On-prem Domain Admin Username"
    default = "azureadmin"
}
variable "domain_admin_password" {
  sensitive   = true
  type        = string 
}

# Jump host module
variable "jump_host_name" {
    type        = string
    default     = "aedev001"
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
    default = "azureadmin"
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
variable "local_network_gateway_prefix" {
    type = list
    description = "Local Network Gateway Address Space OnPrem addresses to advertise"
}

variable "dns1_vm_name" {
    type        = string
    default     = "aednsnva1"
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
variable "dns2_vm_name" {
    type        = string
    default     = "awdnsnva1"
}
variable "dns_nva1_private_ip_addr" {
    type        = string 
    description = "DC1 Private IP Address"
    default     = "10.1.1.5"
}

variable "route_table_prefix" {
  type = string
  description = "Route table prefix"
  default = "10.0.0.0/8"
}
variable "id_spk_region1_infra_subnet_name" {
    type = string
    default = "infra"
}
variable "id_spk_region1_infra_subnet_addr" {
    type = string
    default = "10.3.3.0/24"
}
# Azure Bastion module
variable "azurebastion_name" {
    type        = string
    default     = "corp-bastion-svc"
}
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
variable "lz_vnet_name_prefix" {
    type        = string 
    description = "Landingzone vnet name prefix.  Appended with Region"
    default = "vnet-lz-spk"
}
variable "lz_spk_rg_prefix" {
    type = string
    default =  "net-lz-spk"
}
