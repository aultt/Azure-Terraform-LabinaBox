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
    alias = "management"
    subscription_id = var.management_subscription_id
}

provider "azurerm" {
    features {} 
    alias = "identity"
    subscription_id = var.identity_subscription_id
}

provider "azurerm" {
    features {} 
    alias = "connectivity"
    subscription_id = var.connectivity_subscription_id
}

resource "azurerm_resource_group" "svc_rg" {
    provider = azurerm.management
    name                        = var.svc_resource_group_name
    location                    = var.region1_loc
  tags = {
    "Workload" = "Core Infra"
    "Data Class" = "General"
    "Business Crit" = "High"
  }
}

module "log_analytics" {
  providers = {azurerm = azurerm.management}
  source                          = "../../../../modules//log_analytics"
  resource_group_name             = azurerm_resource_group.svc_rg.name
  location                        = var.region1_loc
  law_name               = "${var.law_prefix}-core-${var.corp_prefix}-001"
}

#AutomationAccount must be in a supported region for linking 
#https://docs.microsoft.com/en-us/azure/automation/how-to/region-mappings
module "automation_account" {
  providers = {azurerm = azurerm.management}
  source                          = "../../../../modules//automation_account"
  resource_group_name             = azurerm_resource_group.svc_rg.name
  automation_location             = var.automation_loc
  law_location                    = var.region1_loc
  name                            = "auto-core-${var.region1_loc}-${var.corp_prefix}"
  law_id                          = module.log_analytics.log_analytics_id
  law_name                        = module.log_analytics.log_analytics_name
}

module "recovery_vault" {
  providers = {azurerm = azurerm.management}
  source = "../../../../modules//recovery_vault"
  resource_group_name = azurerm_resource_group.svc_rg.name
  location = var.region1_loc
  recovery_vault_name = "rv-core-${var.region1_loc}-${var.corp_prefix}"
  recovery_policy_name = "rvp-core-${var.region1_loc}-${var.corp_prefix}"
}

resource "azurerm_resource_group" "hub_region1" {
  provider = azurerm.connectivity
  name     = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
  location = var.region1_loc
  tags     = var.tags
}

resource "azurerm_resource_group" "hub_region2" {
  provider = azurerm.connectivity
  name     = "${var.hub_rg_prefix}-${var.region2_loc}-rg"
  location = var.region2_loc
  tags     = var.tags
}

module "hub_region1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.hub_region1.name
  location            = azurerm_resource_group.hub_region1.location
  vnet_name             = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
  address_space         = var.hub_region1_address_space
  default_subnet_prefixes = [var.hub_region1_default_subnet]
  dns_servers = [var.domain_ip,var.dc1_private_ip_addr,var.dc2_private_ip_addr, "168.63.129.16"]
  route_table_id = azurerm_route_table.Hub-Region1.id
}

module "hub_region1_jumphost_subnet"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/subnet"
  resource_group_name = azurerm_resource_group.hub_region1.name
  vnet_name = module.hub_region1.vnet_name
  location = var.region1_loc
  subnet_name = var.jump_host_subnet_name
  subnet_prefixes = [var.jump_host_addr_prefix]
}

resource "azurerm_subnet_route_table_association" "default" {
  subnet_id      = module.hub_region1_jumphost_subnet.subnet_id
  route_table_id = azurerm_route_table.Hub-Region1.id
}

module "hub_region2" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.hub_region2.name
  location            = azurerm_resource_group.hub_region2.location
  vnet_name             = "${var.hub_vnet_name_prefix}-${var.region2_loc}"
  address_space         = var.hub_region2_address_space
  default_subnet_prefixes = [var.hub_region2_default_subnet]
  dns_servers = [var.domain_ip,var.dc2_private_ip_addr, var.dc1_private_ip_addr, "168.63.129.16"]
  route_table_id = azurerm_route_table.Hub-Region2.id
}
# Peering between hub1 and hub2
module "peering_hubs" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/peering_both"
  resource_group_nameA = azurerm_resource_group.hub_region1.name
  resource_group_nameB = azurerm_resource_group.hub_region2.name
  netA_name            = module.hub_region1.vnet_name
  netA_id              = module.hub_region1.vnet_id
  netB_name            = module.hub_region2.vnet_name
  netB_id              = module.hub_region2.vnet_id
  depends_on = [module.onpremise_VPN_Region1,module.onpremise_VPN_Region2 ]
}

resource "azurerm_resource_group" "id_spk_region1" {
  provider = azurerm.identity
  name     = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
  location = var.region1_loc
  tags     = var.tags
}

# Create idenity spoke for region1
module "id_spk_region1" {
  providers = {azurerm = azurerm.identity}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.id_spk_region1.name
  location            = azurerm_resource_group.id_spk_region1.location
  vnet_name             = "${var.id_spk_vnet_name_prefix}-${var.region1_loc}"
  address_space         = var.id_spk_region1_address_space
  default_subnet_prefixes = [var.id_spk_region1_default_subnet]
  dns_servers = [var.dc1_private_ip_addr,var.domain_ip,var.dc2_private_ip_addr, "168.63.129.16"]
  route_table_id = azurerm_route_table.Identity-Region1.id
}

# Peering between hub1 and spk1
module "peering_id_spk_Region1_1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/peering_direction1"
  resource_group_nameA = azurerm_resource_group.hub_region1.name
  resource_group_nameB = azurerm_resource_group.id_spk_region1.name
  netA_name            = module.hub_region1.vnet_name
  netA_id              = module.hub_region1.vnet_id
  netB_name            = module.id_spk_region1.vnet_name
  netB_id              = module.id_spk_region1.vnet_id
  depends_on = [module.onpremise_VPN_Region1,module.onpremise_VPN_Region2 ]
}

# Peering between hub1 and spk1
module "peering_id_spk_Region1_2" {
  providers = {azurerm = azurerm.identity}
  source = "../../../../modules//networking/peering_direction2"
  resource_group_nameA = azurerm_resource_group.hub_region1.name
  resource_group_nameB = azurerm_resource_group.id_spk_region1.name
  netA_name            = module.hub_region1.vnet_name
  netA_id              = module.hub_region1.vnet_id
  netB_name            = module.id_spk_region1.vnet_name
  netB_id              = module.id_spk_region1.vnet_id
  depends_on = [module.onpremise_VPN_Region1,module.onpremise_VPN_Region2 ]
}

resource "azurerm_resource_group" "id_spk_region2" {
  provider = azurerm.identity
  name     = "${var.id_spk_rg_prefix}-${var.region2_loc}-rg"
  location = var.region2_loc
  tags     = var.tags
}

# Create idenity spoke for region2
module "id_spk_region2" {
  providers = {azurerm = azurerm.identity}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.id_spk_region2.name
  location            = azurerm_resource_group.id_spk_region2.location
  vnet_name             = "${var.id_spk_vnet_name_prefix}-${var.region2_loc}"
  address_space         = var.id_spk_region2_address_space
  default_subnet_prefixes = [var.id_spk_region2_default_subnet]
  dns_servers = [var.dc2_private_ip_addr,var.dc1_private_ip_addr,var.domain_ip,"168.63.129.16"]
  route_table_id = azurerm_route_table.Identity-Region2.id
}

# Peering between hub2 and id_spk2
module "peering_id_spk_Region2_1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/peering_direction1"
  resource_group_nameA = azurerm_resource_group.hub_region2.name
  resource_group_nameB = azurerm_resource_group.id_spk_region2.name
  netA_name            = module.hub_region2.vnet_name
  netA_id              = module.hub_region2.vnet_id
  netB_name            = module.id_spk_region2.vnet_name
  netB_id              = module.id_spk_region2.vnet_id
  depends_on = [module.onpremise_VPN_Region1,module.onpremise_VPN_Region2 ]
}

# Peering between hub2 and id_spk2
module "peering_id_spk_Region2_2" {
  providers = {azurerm = azurerm.identity}
  source = "../../../../modules//networking/peering_direction2"

  resource_group_nameA = azurerm_resource_group.hub_region2.name
  resource_group_nameB = azurerm_resource_group.id_spk_region2.name
  netA_name            = module.hub_region2.vnet_name
  netA_id              = module.hub_region2.vnet_id
  netB_name            = module.id_spk_region2.vnet_name
  netB_id              = module.id_spk_region2.vnet_id
  depends_on = [module.onpremise_VPN_Region1,module.onpremise_VPN_Region2 ]
}

########### Keyvault for Region 1 #####################
module "id_spk_region1_shared_subnet"{
  providers = {azurerm = azurerm.identity}
  source = "../../../../modules//networking/subnet"
  resource_group_name = azurerm_resource_group.id_spk_region1.name
  vnet_name = module.id_spk_region1.vnet_name
  location = var.region1_loc
  subnet_name = var.id_spk_region1_shared_subnet_name
  subnet_prefixes = [var.id_spk_region1_shared_subnet_addr]
}

resource "azurerm_subnet_route_table_association" "default_Region1" {
  provider = azurerm.identity
  subnet_id      = module.id_spk_region1_shared_subnet.subnet_id
  route_table_id = azurerm_route_table.Identity-Region1.id
}

module "idk_shared_keyvault_dns_zone"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//private_dns/zone"
  resource_group_name = azurerm_resource_group.hub_region1.name
  zone_name =  "privatelink.vaultcore.azure.net"
}

module "idk_shared_keyvault_dns_zone_link_region1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//private_dns/link"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "keyvault"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.id_spk_region1.vnet_id
  dns_zone_name = module.idk_shared_keyvault_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "idk_shared_websites_dns_zone"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/zone"
  resource_group_name = azurerm_resource_group.hub_region1.name
  zone_name =  "privatelink.azurewebsites.azure.net"
}
module "idk_shared_websites_dns_zone_link_region1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "ase"
  hub_vnet_id = module.hub_region1.vnet_id
  spoke_vnet_id = module.id_spk_region1.vnet_id
  dns_zone_name = module.idk_shared_websites_dns_zone.dns_zone_name
  location = var.region1_loc
}
module "keyvault_region1" {
    providers = {azurerm = azurerm.identity}
    source  = "../../../../modules//key_vault"
    resource_group_name = azurerm_resource_group.id_spk_region1.name
    location = azurerm_resource_group.id_spk_region1.location
    keyvault_name  = "kv-${var.corp_prefix}-${var.region1_loc}"
    shared_subnetid  = module.id_spk_region1_shared_subnet.subnet_id
    keyvault_zone_name = module.idk_shared_keyvault_dns_zone.dns_zone_name
    keyvault_zone_id = module.idk_shared_keyvault_dns_zone.dns_zone_id
}

############ Keyvault for Region 2 #####################
module "id_spk_region2_shared_subnet"{
  providers = {azurerm = azurerm.identity}
  source = "../../../../modules//networking/subnet"
  resource_group_name = azurerm_resource_group.id_spk_region2.name
  vnet_name = module.id_spk_region2.vnet_name
  location = var.region2_loc
  subnet_name = var.id_spk_region2_shared_subnet_name
  subnet_prefixes = [var.id_spk_region2_shared_subnet_addr]
}

resource "azurerm_subnet_route_table_association" "default_Region2" {
  provider = azurerm.identity
  subnet_id      = module.id_spk_region2_shared_subnet.subnet_id
  route_table_id = azurerm_route_table.Identity-Region2.id
}

module "idk_shared_keyvault_dns_zone_link_region2" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//private_dns/link"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "keyvault"
  hub_vnet_id = module.hub_region2.vnet_id
  spoke_vnet_id = module.id_spk_region2.vnet_id
  dns_zone_name = module.idk_shared_keyvault_dns_zone.dns_zone_name
  location = var.region2_loc
}

module "idk_shared_websites_dns_zone_link_region2" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link"
  resource_group_name = azurerm_resource_group.hub_region1.name
  service_name = "ase"
  hub_vnet_id = module.hub_region2.vnet_id
  spoke_vnet_id = module.id_spk_region2.vnet_id
  dns_zone_name = module.idk_shared_websites_dns_zone.dns_zone_name
  location = var.region2_loc
}

module "keyvault_region2" {
    providers = {azurerm = azurerm.identity}
    source  = "../../../../modules//key_vault"
    resource_group_name = azurerm_resource_group.id_spk_region2.name
    location = azurerm_resource_group.id_spk_region2.location
    keyvault_name  = "kv-${var.corp_prefix}-${var.region2_loc}"
    shared_subnetid  = module.id_spk_region2_shared_subnet.subnet_id
    keyvault_zone_name = module.idk_shared_keyvault_dns_zone.dns_zone_name
    keyvault_zone_id = module.idk_shared_keyvault_dns_zone.dns_zone_id
}

# Bastion Host
module "bastion_region1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//azure_bastion"
  resource_group_name  = azurerm_resource_group.hub_region1.name
  location             = var.region1_loc
  azurebastion_name = var.azurebastion_name
  azurebastion_vnet_name = module.hub_region1.vnet_name
  azurebastion_addr_prefix = var.bastion_addr_prefix
}

resource "azurerm_key_vault_secret" "local_admin_username_Region1" {
  provider = azurerm.identity
  name = "local-admin-username"
  value = var.jump_host_admin_username
  key_vault_id = module.keyvault_region1.vault_id
}

resource "azurerm_key_vault_secret" "local_admin_password_Region1" {
  provider = azurerm.identity
  name = "local-admin-password"
  value = var.jump_host_password
  key_vault_id = module.keyvault_region1.vault_id
}

resource "azurerm_key_vault_secret" "domain_admin_password_Region1" {
  provider = azurerm.identity
  name = "domain-admin-password"
  value = var.domain_admin_password
  key_vault_id = module.keyvault_region1.vault_id
}

resource "azurerm_key_vault_secret" "local_admin_username_Region2" {
  provider = azurerm.identity
  name = "local-admin-username"
  value = var.jump_host_admin_username
  key_vault_id = module.keyvault_region2.vault_id
}

resource "azurerm_key_vault_secret" "local_admin_password_Region2" {
  provider = azurerm.identity
  name = "local-admin-password"
  value = var.jump_host_password
  key_vault_id = module.keyvault_region2.vault_id
}

resource "azurerm_key_vault_secret" "domain_admin_password_Region2" {
  provider = azurerm.identity
  name = "domain-admin-password"
  value = var.domain_admin_password
  key_vault_id = module.keyvault_region2.vault_id
}

module "DSC_config" {
  providers = {azurerm = azurerm.management}
  source = "../../../../modules/dsc_configuration"
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

module "onpremise_VPN_Region1"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/vpn"
  resource_group_name =azurerm_resource_group.hub_region1.name
  location = azurerm_resource_group.hub_region1.location
  vnet_name = module.hub_region1.vnet_name
  subnet_prefixes = var.gateway_address_prefix
  gateway_ip_address = var.gateway_ip_address
  local_network_gateway_prefix = var.local_network_gateway_prefix
  gateway_address_prefix = var.gateway_address_prefix
  local_network_gateway_name = var.local_network_gateway_name
  gateway_pip_name = "${var.gateway_pip_name}-${var.region1_loc}"
  gateway_name = "${var.gateway_name}-${var.region1_loc}"
  s2s_connection_name ="${var.s2s_connection_name}-${var.region1_loc}"
  shared_key = var.Vpn_shared_key
  depends_on = [module.hub_region1_jumphost_subnet,module.bastion_region1]
}

module "onpremise_VPN_Region2"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/vpn"
  resource_group_name =azurerm_resource_group.hub_region2.name
  location = azurerm_resource_group.hub_region2.location
  vnet_name = module.hub_region2.vnet_name
  subnet_prefixes = var.region2_gateway_address_prefix
  gateway_ip_address = var.gateway_ip_address
  local_network_gateway_prefix = var.local_network_gateway_prefix
  gateway_address_prefix = var.region2_gateway_address_prefix
  local_network_gateway_name = var.local_network_gateway_name
  gateway_pip_name = "${var.gateway_pip_name}-${var.region2_loc}"
  gateway_name = "${var.gateway_name}-${var.region2_loc}"
  s2s_connection_name ="${var.s2s_connection_name}-${var.region2_loc}"
  shared_key = var.Vpn_shared_key
}

resource "azurerm_route_table" "Hub-Region2" {
  provider = azurerm.connectivity
  name                          = "RT-${var.hub_vnet_name_prefix}-${var.region2_loc}"
  location                      = azurerm_resource_group.hub_region2.location
  resource_group_name           = azurerm_resource_group.hub_region2.name

  route {
    name           = "Route-${var.hub_vnet_name_prefix}-${var.region2_loc}-HubNva"
    address_prefix = "10.0.0.0/8"
    next_hop_in_ip_address = var.dns_nva1_private_ip_addr
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_route_table" "Hub-Region1" {
  provider = azurerm.connectivity
  name                          = "RT-${var.hub_vnet_name_prefix}-${var.region1_loc}"
  location                      = azurerm_resource_group.hub_region1.location
  resource_group_name           = azurerm_resource_group.hub_region1.name

  route {
    name           = "Route-${var.hub_vnet_name_prefix}-${var.region1_loc}-HubNva"
    address_prefix = "10.0.0.0/8"
    next_hop_in_ip_address = var.dns_nva2_private_ip_addr
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_route_table" "Identity-Region1" {
  provider = azurerm.identity
  name                          = "RT-${var.id_spk_rg_prefix}-${var.region1_loc}"
  location                      = azurerm_resource_group.id_spk_region1.location
  resource_group_name           = azurerm_resource_group.id_spk_region1.name

  route {
    name           = "Route-${var.id_spk_rg_prefix}-${var.region1_loc}-HubNva"
    address_prefix = "10.0.0.0/8"
    next_hop_in_ip_address = var.dns_nva1_private_ip_addr
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_route_table" "Identity-Region2" {
  provider = azurerm.identity
  name                          = "RT-${var.id_spk_rg_prefix}-${var.region2_loc}"
  location                      = azurerm_resource_group.id_spk_region2.location
  resource_group_name           = azurerm_resource_group.id_spk_region2.name

  route {
    name           = "Route-${var.id_spk_rg_prefix}-${var.region2_loc}-HubNva"
    address_prefix = "10.0.0.0/8"
    next_hop_in_ip_address = var.dns_nva2_private_ip_addr
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}

