# Azure provider version 

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.52"
    }
  }
}
provider "azurerm" {
    features {} 
}

provider "azurerm" {
    features {} 
    alias = "poc"
    subscription_id = var.poc_subscription_id
}
variable "dns_servers" {
  default =["168.63.129.16"]
}
locals{
  dns_servers = var.hybrid_deployment ? [var.domain_ip,var.dc1_private_ip_addr,"168.63.129.16"] : ["168.63.129.16"]
}
resource "azurerm_resource_group" "svc_rg" {
    provider = azurerm.poc
    name     = "${var.svc_rg_prefix}-${var.region1_loc}-rg"
    location                    = var.region1_loc
  tags = {
    "Workload" = "Core Infra"
    "Data Class" = "General"
    "Business Crit" = "High"
  }
}

module "log_analytics" {
  providers = {azurerm = azurerm.poc}
  source                          = "../../../../modules//log_analytics"
  resource_group_name             = azurerm_resource_group.svc_rg.name
  location                        = var.region1_loc
  law_name               = "${var.law_prefix}-core-${var.corp_prefix}-001"
}

#AutomationAccount must be in a supported region for linking 
#https://docs.microsoft.com/en-us/azure/automation/how-to/region-mappings
module "automation_account" {
  providers = {azurerm = azurerm.poc}
  source                          = "../../../../modules//automation_account"
  resource_group_name             = azurerm_resource_group.svc_rg.name
  automation_location             = var.automation_loc
  law_location                    = var.region1_loc
  name                            = "auto-core-${var.region1_loc}-${var.corp_prefix}"
  law_id                          = module.log_analytics.log_analytics_id
  law_name                        = module.log_analytics.log_analytics_name
}

resource "azurerm_resource_group" "hub_region1" {
  provider = azurerm.poc
  name     = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
  location = var.region1_loc
  tags     = var.tags
}
resource "azurerm_route_table" "Hub-Region1" {
  provider = azurerm.poc
  name                          = "RT-${var.hub_vnet_name_prefix}-${var.region1_loc}"
  location                      = azurerm_resource_group.hub_region1.location
  resource_group_name           = azurerm_resource_group.hub_region1.name

  route {
    name           = "Route-${var.hub_vnet_name_prefix}-${var.region1_loc}-HubNva"
    address_prefix = var.route_table_prefix
    next_hop_in_ip_address = "0.0.0.0"
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}

module "hub_region1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/networking/vnet"
  resource_group_name = azurerm_resource_group.hub_region1.name
  location            = azurerm_resource_group.hub_region1.location
  vnet_name             = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
  address_space         = var.hub_region1_address_space
  default_subnet_prefixes = [var.hub_region1_default_subnet]
  dns_servers = local.dns_servers
  route_table_id = azurerm_route_table.Hub-Region1.id
}
module "hub_region1_jumphost_subnet"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/networking/subnet"
  resource_group_name = azurerm_resource_group.hub_region1.name
  vnet_name = module.hub_region1.vnet_name
  location = var.region1_loc
  subnet_name = var.jump_host_subnet_name
  subnet_prefixes = [var.jump_host_addr_prefix]
}

resource "azurerm_subnet_route_table_association" "default" {
  provider = azurerm.poc
  subnet_id      = module.hub_region1_jumphost_subnet.subnet_id
  route_table_id = azurerm_route_table.Hub-Region1.id
}

resource "azurerm_resource_group" "id_spk_region1" {
  provider = azurerm.poc
  name     = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
  location = var.region1_loc
  tags     = var.tags
}

resource "azurerm_route_table" "Identity-Region1" {
  provider = azurerm.poc
  name                          = "RT-${var.id_spk_rg_prefix}-${var.region1_loc}"
  location                      = azurerm_resource_group.id_spk_region1.location
  resource_group_name           = azurerm_resource_group.id_spk_region1.name

  route {
    name           = "Route-${var.id_spk_rg_prefix}-${var.region1_loc}-HubNva"
    address_prefix = var.route_table_prefix
    next_hop_in_ip_address = var.dns_nva1_private_ip_addr
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}

# Create idenity spoke for region1
module "id_spk_region1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/networking/vnet"
  resource_group_name = azurerm_resource_group.id_spk_region1.name
  location            = azurerm_resource_group.id_spk_region1.location
  vnet_name             = "${var.id_spk_vnet_name_prefix}-${var.region1_loc}"
  address_space         = var.id_spk_region1_address_space
  default_subnet_prefixes = [var.id_spk_region1_default_subnet]
  dns_servers = local.dns_servers
  route_table_id = azurerm_route_table.Identity-Region1.id
}


module "onprem_VPN_Region1"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/vpn"
  count = var.hybrid_deployment ? 1 : 0
  resource_group_name =azurerm_resource_group.hub_region1.name
  location = azurerm_resource_group.hub_region1.location
  vnet_name = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
  subnet_prefixes = var.gateway_address_prefix
  gateway_ip_address = var.gateway_ip_address
  local_network_gateway_prefix = var.local_network_gateway_prefix
  gateway_address_prefix = var.gateway_address_prefix
  local_network_gateway_name = "${var.corp_prefix}-OnPrem"
  gateway_pip_name = "${var.corp_prefix}-vpg-ip-${var.region1_loc}"
  gateway_name = "${var.corp_prefix}-vpg-${var.region1_loc}"
  s2s_connection_name ="${var.corp_prefix}-s2s-conn-${var.region1_loc}"
  shared_key = var.Vpn_shared_key
  depends_on = [module.hub_region1_jumphost_subnet]
}

module "id_spk_region1_shared_subnet"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//networking/subnet"
  resource_group_name = azurerm_resource_group.id_spk_region1.name
  vnet_name = module.id_spk_region1.vnet_name
  location = var.region1_loc
  subnet_name = var.id_spk_region1_shared_subnet_name
  subnet_prefixes = [var.id_spk_region1_shared_subnet_addr]
}

resource "azurerm_subnet_route_table_association" "default_Region1" {
  provider = azurerm.poc
  subnet_id      = module.id_spk_region1_shared_subnet.subnet_id
  route_table_id = azurerm_route_table.Identity-Region1.id
}

module "idk_shared_keyvault_dns_zone"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//private_dns/zone"
  resource_group_name = azurerm_resource_group.hub_region1.name
  zone_name =  "privatelink.vaultcore.azure.net"
}

module "idk_shared_websites_dns_zone"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/zone"
  resource_group_name = azurerm_resource_group.hub_region1.name
  zone_name =  "privatelink.azurewebsites.azure.net"
}

module "keyvault_region1" {
    providers = {azurerm = azurerm.poc}
    source  = "../../../../modules/key_vault"
    resource_group_name = azurerm_resource_group.id_spk_region1.name
    location = azurerm_resource_group.id_spk_region1.location
    keyvault_name  = "kv-${var.corp_prefix}-${var.region1_loc}"
    shared_subnetid  = module.id_spk_region1_shared_subnet.subnet_id
    keyvault_zone_name = module.idk_shared_keyvault_dns_zone.dns_zone_name
    keyvault_zone_id = module.idk_shared_keyvault_dns_zone.dns_zone_id
}

resource "azurerm_key_vault_secret" "local_admin_username_Region1" {
  provider = azurerm.poc
  name = "local-admin-username"
  value = var.jump_host_admin_username
  key_vault_id = module.keyvault_region1.vault_id
}

resource "azurerm_key_vault_secret" "local_admin_password_Region1" {
  provider = azurerm.poc
  name = "local-admin-password"
  value = var.jump_host_password
  key_vault_id = module.keyvault_region1.vault_id
}

resource "azurerm_key_vault_secret" "domain_admin_password_Region1" {
  provider = azurerm.poc
  name = "domain-admin-password"
  value = var.domain_admin_password
  key_vault_id = module.keyvault_region1.vault_id
}

module "DSC_config" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/dsc_configuration/"
  domain_name        = var.domain_name
  domain_user        = "${var.domain_NetbiosName}\\${var.domain_admin_username}"
  admin_password     = var.jump_host_admin_username
  admin_username     = var.jump_host_password
  domain_NetbiosName = var.domain_NetbiosName
  domain_login        =  "${var.domain_admin_username}@${var.domain_name}"   
  domain_admin_password = var.domain_admin_password 
  domain_ip = var.domain_ip           
  automation_account_name = module.automation_account.name
  resource_group_name = module.automation_account.resource_group_name
  location = var.automation_loc
  dns1_name = var.dns1_vm_name
  dns2_name = var.dns2_vm_name
  jump_host_name = var.jump_host_name
  dc1_private_ip_addr = var.dc1_private_ip_addr
  dc2_private_ip_addr = var.dc2_private_ip_addr
}

resource "null_resource" "PowerShellCompileDSC"{
    triggers = {
      trigger = "{uuid()}"
    }
    provisioner "local-exec" {
        command = ".'${path.module}/PowerShell/compileDSCConfigurationwithParam.ps1' -subscriptionId ${var.poc_subscription_id} -resourceGroupName ${azurerm_resource_group.svc_rg.name} -automationAccountName ${module.automation_account.name}"
        interpreter = ["pwsh","-Command"]    
  }
  depends_on = [module.DSC_config]
}


module "id_spk_region1_infra_subnet_Region1"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/networking/subnet"
  resource_group_name = azurerm_resource_group.id_spk_region1.name
  vnet_name = module.id_spk_region1.vnet_name
  location = var.region1_loc
  subnet_name = var.id_spk_region1_infra_subnet_name
  subnet_prefixes = [var.id_spk_region1_infra_subnet_addr]
}

resource "azurerm_subnet_route_table_association" "infra_Region1" {
  provider = azurerm.poc
  subnet_id      = module.id_spk_region1_infra_subnet_Region1.subnet_id
  route_table_id = azurerm_route_table.Identity-Region1.id
}

# Peering between hub1 and spk1
module "peering_id_spk_Region1_1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/networking/peering_direction1"
  resource_group_nameA = azurerm_resource_group.hub_region1.name
  resource_group_nameB = azurerm_resource_group.id_spk_region1.name
  netA_name            = module.hub_region1.vnet_name
  netA_id              = module.hub_region1.vnet_id
  netB_name            = module.id_spk_region1.vnet_name
  netB_id              = module.id_spk_region1.vnet_id
  gateway_transit = var.hybrid_deployment ? true : false
}

# Peering between hub1 and spk1
module "peering_id_spk_Region1_2" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//networking/peering_direction2"
  resource_group_nameA = azurerm_resource_group.hub_region1.name
  resource_group_nameB = azurerm_resource_group.id_spk_region1.name
  netA_name            = module.hub_region1.vnet_name
  netA_id              = module.hub_region1.vnet_id
  netB_name            = module.id_spk_region1.vnet_name
  netB_id              = module.id_spk_region1.vnet_id
  remote_gateways      = var.hybrid_deployment ? true : false
}

module "idk_shared_keyvault_dns_zone_link_region1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//private_dns/link"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "keyvault"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.id_spk_region1.vnet_id
  dns_zone_name = "privatelink.vaultcore.azure.net"
  location = var.region1_loc
}

module "idk_shared_websites_dns_zone_link_region1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/link"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "ase"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.id_spk_region1.vnet_id
  dns_zone_name = "privatelink.azurewebsites.azure.net"
  location = var.region1_loc
}

resource "azurerm_resource_group" "lz_spk_region1" {
  provider = azurerm.poc
  name     = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
  location = var.region1_loc
    tags = {
    "Workload" = "Core Infra"
    "Data Class" = "High"
    "Business Crit" = "High"
  }
}

module "lz_spk_region1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.lz_spk_region1.name
  location            = azurerm_resource_group.lz_spk_region1.location
  vnet_name             = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
  address_space         = var.lz_address_space_region1
  default_subnet_prefixes = [var.lz_dsubnet_address_space_region1]
  dns_servers = var.hybrid_deployment ? [var.dc1_private_ip_addr, "168.63.129.16"] :["168.63.129.16"]
  route_table_id = azurerm_route_table.LandingZone-Region1.id
}

# Peering between hub1 and landingzone1
module "peering_lz_spk_Region1_1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//networking/peering_direction1"
  resource_group_nameA = azurerm_resource_group.hub_region1.name
  resource_group_nameB = azurerm_resource_group.lz_spk_region1.name
  netA_name            = module.hub_region1.vnet_name
  netA_id              = module.hub_region1.vnet_id
  netB_name            = module.lz_spk_region1.vnet_name
  netB_id              = module.lz_spk_region1.vnet_id
  gateway_transit = var.hybrid_deployment ? true : false
}

# Peering between hub1 and landingzone1
module "peering_id_lz_Region1_2" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//networking/peering_direction2"
  resource_group_nameA = azurerm_resource_group.hub_region1.name
  resource_group_nameB = azurerm_resource_group.lz_spk_region1.name
  netA_name            = module.hub_region1.vnet_name
  netA_id              = module.hub_region1.vnet_id
  netB_name            = module.lz_spk_region1.vnet_name
  netB_id              = module.lz_spk_region1.vnet_id
  remote_gateways      = var.hybrid_deployment ? true : false
  depends_on = [module.peering_lz_spk_Region1_1]
}

resource "azurerm_resource_group" "sb_spk_region1" {
  provider = azurerm.poc
  name     = "${var.sb_spk_rg_prefix}-${var.region1_loc}-rg"
  location = var.region1_loc
    tags = {
    "Workload" = "Core Infra"
    "Data Class" = "High"
    "Business Crit" = "High"
  }
}

# Create Sandbox for region1
module "sb_spk_region1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.sb_spk_region1.name
  location            = azurerm_resource_group.sb_spk_region1.location
  vnet_name             = "${var.sb_vnet_name_prefix}-${var.region1_loc}"
  address_space         = var.sb_address_space_region1
  default_subnet_prefixes = [var.sb_dsubnet_address_space_region1]
  dns_servers = [var.dc1_private_ip_addr,"168.63.129.16"]
  route_table_id = azurerm_route_table.SandBox-Region1.id
}

# Peering between hub1 and landingzone1
module "peering_sb_spk_Region1_1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//networking/peering_direction1"
  resource_group_nameA = azurerm_resource_group.hub_region1.name
  resource_group_nameB = azurerm_resource_group.sb_spk_region1.name
  netA_name            = module.hub_region1.vnet_name
  netA_id              = module.hub_region1.vnet_id
  netB_name            = module.sb_spk_region1.vnet_name
  netB_id              = module.sb_spk_region1.vnet_id
  gateway_transit = var.hybrid_deployment ? true : false
}

# Peering between hub1 and landingzone1
module "peering_sb_spk_Region1_2" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules//networking/peering_direction2"
  resource_group_nameA = azurerm_resource_group.hub_region1.name
  resource_group_nameB = azurerm_resource_group.sb_spk_region1.name
  netA_name            = module.hub_region1.vnet_name
  netA_id              = module.hub_region1.vnet_id
  netB_name            = module.sb_spk_region1.vnet_name
  netB_id              = module.sb_spk_region1.vnet_id
  remote_gateways      = var.hybrid_deployment ? true : false
  depends_on = [module.peering_sb_spk_Region1_1]
}

#Add Storage Private Zone and Link to all vnets
module "idk_shared_storage_dns_zone"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/zone"
  resource_group_name = azurerm_resource_group.hub_region1.name
  zone_name =  "privatelink.blob.core.windows.net"
}

module "idk_shared_storage_dns_zone_link_region1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/link"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "storage"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.id_spk_region1.vnet_id
  dns_zone_name = module.idk_shared_storage_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "lz_storage_dns_zone_link_region1"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "storage"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.lz_spk_region1.vnet_id
  spoke_prefix = "lz"
  dns_zone_name = module.idk_shared_storage_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "sb_storage_dns_zone_link_region1"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "storage"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.sb_spk_region1.vnet_id
  spoke_prefix = "sb"
  dns_zone_name = module.idk_shared_storage_dns_zone.dns_zone_name
  location = var.region1_loc
}

#SQL Private DNS Zone
#Add Storage Private Zone and Link to all vnets
module "idk_shared_sql_dns_zone"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/zone"
  resource_group_name = azurerm_resource_group.hub_region1.name
  zone_name =  "privatelink.database.windows.net"
}

module "idk_shared_sql_dns_zone_link_region1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/link"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "sql"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.id_spk_region1.vnet_id
  dns_zone_name = module.idk_shared_sql_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "lz_sql_dns_zone_link_region1"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "sql"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.lz_spk_region1.vnet_id
  spoke_prefix = "lz"
  dns_zone_name = module.idk_shared_sql_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "sb_sql_dns_zone_link_region1"{
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "sql"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.sb_spk_region1.vnet_id
  spoke_prefix = "sb"
  dns_zone_name = module.idk_shared_sql_dns_zone.dns_zone_name
  location = var.region1_loc
}

resource "azurerm_route_table" "LandingZone-Region1" {
  provider = azurerm.poc
  name                          = "RT-${var.lz_spk_rg_prefix}-${var.region1_loc}"
  location                      = azurerm_resource_group.lz_spk_region1.location
  resource_group_name           = azurerm_resource_group.lz_spk_region1.name

  route {
    name           = "Route-${var.lz_spk_rg_prefix}-${var.region1_loc}-HubNva"
    address_prefix = "10.0.0.0/8"
    next_hop_in_ip_address = var.dns_nva1_private_ip_addr
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_route_table" "SandBox-Region1" {
  provider = azurerm.poc
  name                          = "RT-${var.sb_spk_rg_prefix}-${var.region1_loc}"
  location                      = azurerm_resource_group.sb_spk_region1.location
  resource_group_name           = azurerm_resource_group.sb_spk_region1.name

  route {
    name           = "Route-${var.sb_spk_rg_prefix}-${var.region1_loc}-HubNva"
    address_prefix = "10.0.0.0/8"
    next_hop_in_ip_address = var.dns_nva1_private_ip_addr
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}
# Bastion Host
module "bastion_region1" {
  providers = {azurerm = azurerm.poc}
  source = "../../../../modules/azure_bastion"
  resource_group_name  = azurerm_resource_group.hub_region1.name
  location = var.region1_loc
  azurebastion_name = var.azurebastion_name
  azurebastion_vnet_name = module.hub_region1.vnet_name
  azurebastion_addr_prefix = var.bastion_addr_prefix
}
