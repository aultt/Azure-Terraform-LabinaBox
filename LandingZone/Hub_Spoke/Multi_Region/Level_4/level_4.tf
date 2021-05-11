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

provider "azurerm" {
    features {} 
    alias = "landingzone"
    subscription_id = var.landingzone_subscription_id
}

data "azurerm_virtual_network" "hub_region1" {
  provider = azurerm.connectivity
  name                = "vnet-hub-${var.region1_loc}"
  resource_group_name = "net-core-hub-${var.region1_loc}-rg"
}

data "azurerm_virtual_network" "hub_region2" {
  provider = azurerm.connectivity
  name                = "vnet-hub-${var.region2_loc}"
  resource_group_name = "net-core-hub-${var.region2_loc}-rg"
}

data "azurerm_virtual_network" "id_spk_region1" {
  provider = azurerm.identity
  name                = "${var.id_spk_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_virtual_network" "id_spk_region2" {
  provider = azurerm.identity
  name                = "${var.id_spk_vnet_name_prefix}-${var.region2_loc}"
  resource_group_name = "${var.id_spk_rg_prefix}-${var.region2_loc}-rg"
}

resource "azurerm_resource_group" "lz_spk_region1" {
  provider = azurerm.landingzone
  name     = "${var.lz_spk_rg_prefix}-${var.region1_loc}-rg"
  location = var.region1_loc
    tags = {
    "Workload" = "Core Infra"
    "Data Class" = "High"
    "Business Crit" = "High"
  }
}

resource "azurerm_resource_group" "lz_spk_region2" {
  provider = azurerm.landingzone
  name     = "${var.lz_spk_rg_prefix}-${var.region2_loc}-rg"
  location = var.region2_loc
    tags = {
    "Workload" = "Core Infra"
    "Data Class" = "High"
    "Business Crit" = "High"
  }
}

# Create Landingzone for region1
module "lz_spk_region1" {
  providers = {azurerm = azurerm.landingzone}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.lz_spk_region1.name
  location            = azurerm_resource_group.lz_spk_region1.location
  vnet_name             = "${var.lz_vnet_name_prefix}-${var.region1_loc}"
  address_space         = var.lz_address_space_region1
  default_subnet_prefixes = [var.lz_dsubnet_address_space_region1]
  dns_servers = [var.dc_region1_ip,var.dc_region2_ip,"168.63.129.16"]
  route_table_id = azurerm_route_table.LandingZone-Region1.id
}

# Peering between hub1 and landingzone1
module "peering_lz_spk_Region1_1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/peering_direction1"
  resource_group_nameA = data.azurerm_virtual_network.hub_region1.resource_group_name
  resource_group_nameB = azurerm_resource_group.lz_spk_region1.name
  netA_name            = data.azurerm_virtual_network.hub_region1.name
  netA_id              = data.azurerm_virtual_network.hub_region1.id
  netB_name            = module.lz_spk_region1.vnet_name
  netB_id              = module.lz_spk_region1.vnet_id
}

# Peering between hub1 and landingzone1
module "peering_id_spk_Region1_2" {
  providers = {azurerm = azurerm.landingzone}
  source = "../../../../modules//networking/peering_direction2"
  resource_group_nameA = data.azurerm_virtual_network.hub_region1.resource_group_name
  resource_group_nameB = azurerm_resource_group.lz_spk_region1.name
  netA_name            = data.azurerm_virtual_network.hub_region1.name
  netA_id              = data.azurerm_virtual_network.hub_region1.id
  netB_name            = module.lz_spk_region1.vnet_name
  netB_id              = module.lz_spk_region1.vnet_id

  depends_on = [module.peering_lz_spk_Region1_1]
}
# Create landingzone  for region2
module "lz_spk_region2" {
  providers = {azurerm = azurerm.landingzone}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.lz_spk_region2.name
  location            = azurerm_resource_group.lz_spk_region2.location
  vnet_name             = "${var.lz_vnet_name_prefix}-${var.region2_loc}"
  address_space         = var.lz_address_space_region2
  default_subnet_prefixes = [var.lz_dsubnet_address_space_region2]
  dns_servers = [var.dc_region2_ip,var.dc_region1_ip,"168.63.129.16"]
  route_table_id = azurerm_route_table.LandingZone-Region2.id
}

# Peering between hub1 and Landinzone2
module "peering_lz_spk_Region2_1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/peering_direction1"
  resource_group_nameA = data.azurerm_virtual_network.hub_region2.resource_group_name
  resource_group_nameB = azurerm_resource_group.lz_spk_region2.name
  netA_name            = data.azurerm_virtual_network.hub_region2.name
  netA_id              = data.azurerm_virtual_network.hub_region2.id
  netB_name            = module.lz_spk_region2.vnet_name
  netB_id              = module.lz_spk_region2.vnet_id
}

# Peering between hub2 and landingzone2
module "peering_lz_spk_Region2_2" {
  providers = {azurerm = azurerm.landingzone}
  source = "../../../../modules//networking/peering_direction2"
  resource_group_nameA = data.azurerm_virtual_network.hub_region2.resource_group_name
  resource_group_nameB = azurerm_resource_group.lz_spk_region2.name
  netA_name            = data.azurerm_virtual_network.hub_region2.name
  netA_id              = data.azurerm_virtual_network.hub_region2.id
  netB_name            = module.lz_spk_region2.vnet_name
  netB_id              = module.lz_spk_region2.vnet_id

  depends_on = [module.peering_lz_spk_Region2_1]
}

module "peering_lz_spk_region1_region2" {
  providers = {azurerm = azurerm.landingzone}
  source = "../../../../modules//networking/peering_both"
  netA_name = module.lz_spk_region1.vnet_name
  netB_name = module.lz_spk_region2.vnet_name
  netA_id = module.lz_spk_region1.vnet_id
  netB_id = module.lz_spk_region2.vnet_id
  resource_group_nameA = azurerm_resource_group.lz_spk_region1.name
  resource_group_nameB = azurerm_resource_group.lz_spk_region2.name
}

resource "azurerm_resource_group" "sb_spk_region1" {
  provider = azurerm.landingzone
  name     = "${var.sb_spk_rg_prefix}-${var.region1_loc}-rg"
  location = var.region1_loc
    tags = {
    "Workload" = "Core Infra"
    "Data Class" = "High"
    "Business Crit" = "High"
  }
}

resource "azurerm_resource_group" "sb_spk_region2" {
  provider = azurerm.landingzone
  name     = "${var.sb_spk_rg_prefix}-${var.region2_loc}-rg"
  location = var.region2_loc
    tags = {
    "Workload" = "Core Infra"
    "Data Class" = "High"
    "Business Crit" = "High"
  }
}

# Create Sandbox for region1
module "sb_spk_region1" {
  providers = {azurerm = azurerm.landingzone}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.sb_spk_region1.name
  location            = azurerm_resource_group.sb_spk_region1.location
  vnet_name             = "${var.sb_vnet_name_prefix}-${var.region1_loc}"
  address_space         = var.sb_address_space_region1
  default_subnet_prefixes = [var.sb_dsubnet_address_space_region1]
  dns_servers = [var.dc_region1_ip,var.dc_region2_ip,"168.63.129.16"]
  route_table_id = azurerm_route_table.SandBox-Region1.id
}

# Peering between hub1 and landingzone1
module "peering_sb_spk_Region1_1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/peering_direction1"
  resource_group_nameA = data.azurerm_virtual_network.hub_region1.resource_group_name
  resource_group_nameB = azurerm_resource_group.sb_spk_region1.name
  netA_name            = data.azurerm_virtual_network.hub_region1.name
  netA_id              = data.azurerm_virtual_network.hub_region1.id
  netB_name            = module.sb_spk_region1.vnet_name
  netB_id              = module.sb_spk_region1.vnet_id
}

# Peering between hub1 and landingzone1
module "peering_sb_spk_Region1_2" {
  providers = {azurerm = azurerm.landingzone}
  source = "../../../../modules//networking/peering_direction2"
  resource_group_nameA = data.azurerm_virtual_network.hub_region1.resource_group_name
  resource_group_nameB = azurerm_resource_group.sb_spk_region1.name
  netA_name            = data.azurerm_virtual_network.hub_region1.name
  netA_id              = data.azurerm_virtual_network.hub_region1.id
  netB_name            = module.sb_spk_region1.vnet_name
  netB_id              = module.sb_spk_region1.vnet_id

  depends_on = [module.peering_sb_spk_Region1_1]
}
# Create landingzone  for region2
module "sb_spk_region2" {
  providers = {azurerm = azurerm.landingzone}
  source = "../../../../modules//networking/vnet"
  resource_group_name = azurerm_resource_group.sb_spk_region2.name
  location            = azurerm_resource_group.sb_spk_region2.location
  vnet_name             = "${var.sb_vnet_name_prefix}-${var.region2_loc}"
  address_space         = var.sb_address_space_region2
  default_subnet_prefixes = [var.sb_dsubnet_address_space_region2]
  dns_servers = [var.dc_region2_ip,var.dc_region1_ip,"168.63.129.16"]
  route_table_id = azurerm_route_table.SandBox-Region2.id
}

# Peering between hub1 and Landinzone2
module "peering_sb_spk_Region2_1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules//networking/peering_direction1"
  resource_group_nameA = data.azurerm_virtual_network.hub_region2.resource_group_name
  resource_group_nameB = azurerm_resource_group.sb_spk_region2.name
  netA_name            = data.azurerm_virtual_network.hub_region2.name
  netA_id              = data.azurerm_virtual_network.hub_region2.id
  netB_name            = module.sb_spk_region2.vnet_name
  netB_id              = module.sb_spk_region2.vnet_id
}

# Peering between hub2 and landingzone2
module "peering_sb_spk_Region2_2" {
  providers = {azurerm = azurerm.landingzone}
  source = "../../../../modules//networking/peering_direction2"
  resource_group_nameA = data.azurerm_virtual_network.hub_region2.resource_group_name
  resource_group_nameB = azurerm_resource_group.sb_spk_region2.name
  netA_name            = data.azurerm_virtual_network.hub_region2.name
  netA_id              = data.azurerm_virtual_network.hub_region2.id
  netB_name            = module.sb_spk_region2.vnet_name
  netB_id              = module.sb_spk_region2.vnet_id

  depends_on = [module.peering_sb_spk_Region2_1]
}

#Add Storage Private Zone and Link to all vnets
module "idk_shared_storage_dns_zone"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/zone"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  zone_name =  "privatelink.blob.core.windows.net"
}

module "idk_shared_storage_dns_zone_link_region1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "storage"
  hub_vnet_id = data.azurerm_virtual_network.hub_region1.id
  spoke_vnet_id = data.azurerm_virtual_network.id_spk_region1.id
  dns_zone_name = module.idk_shared_storage_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "idk_shared_storage_dns_zone_link_region2" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "storage"
  hub_vnet_id = data.azurerm_virtual_network.hub_region2.id
  spoke_vnet_id = data.azurerm_virtual_network.id_spk_region2.id
  dns_zone_name = module.idk_shared_storage_dns_zone.dns_zone_name
  location = var.region2_loc
}

module "lz_storage_dns_zone_link_region1"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "storage"
  hub_vnet_id = data.azurerm_virtual_network.hub_region1.id
  spoke_vnet_id = module.lz_spk_region1.vnet_id
  spoke_prefix = "lz"
  dns_zone_name = module.idk_shared_storage_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "lz_storage_dns_zone_link_region2"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "storage"
  hub_vnet_id = data.azurerm_virtual_network.hub_region2.id
  spoke_vnet_id = module.lz_spk_region2.vnet_id
  spoke_prefix = "lz"
  dns_zone_name = module.idk_shared_storage_dns_zone.dns_zone_name
  location = var.region2_loc
}

module "sb_storage_dns_zone_link_region1"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "storage"
  hub_vnet_id = data.azurerm_virtual_network.hub_region1.id
  spoke_vnet_id = module.sb_spk_region1.vnet_id
  spoke_prefix = "sb"
  dns_zone_name = module.idk_shared_storage_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "sb_storage_dns_zone_link_region2"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "storage"
  hub_vnet_id = data.azurerm_virtual_network.hub_region2.id
  spoke_vnet_id = module.sb_spk_region2.vnet_id
  spoke_prefix = "sb"
  dns_zone_name = module.idk_shared_storage_dns_zone.dns_zone_name
  location = var.region2_loc
}

#SQL Private DNS Zone
#Add Storage Private Zone and Link to all vnets
module "idk_shared_sql_dns_zone"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/zone"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  zone_name =  "privatelink.database.windows.net"
}

module "idk_shared_sql_dns_zone_link_region1" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "sql"
  hub_vnet_id = data.azurerm_virtual_network.hub_region1.id
  spoke_vnet_id = data.azurerm_virtual_network.id_spk_region1.id
  dns_zone_name = module.idk_shared_sql_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "idk_shared_sql_dns_zone_link_region2" {
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "sql"
  hub_vnet_id = data.azurerm_virtual_network.hub_region2.id
  spoke_vnet_id = data.azurerm_virtual_network.id_spk_region2.id
  dns_zone_name = module.idk_shared_sql_dns_zone.dns_zone_name
  location = var.region2_loc
}

module "lz_sql_dns_zone_link_region1"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "sql"
  hub_vnet_id = data.azurerm_virtual_network.hub_region1.id
  spoke_vnet_id = module.lz_spk_region1.vnet_id
  spoke_prefix = "lz"
  dns_zone_name = module.idk_shared_sql_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "lz_sql_dns_zone_link_region2"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "sql"
  hub_vnet_id = data.azurerm_virtual_network.hub_region2.id
  spoke_vnet_id = module.lz_spk_region2.vnet_id
  spoke_prefix = "lz"
  dns_zone_name = module.idk_shared_sql_dns_zone.dns_zone_name
  location = var.region2_loc
}

module "sb_sql_dns_zone_link_region1"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "sql"
  hub_vnet_id = data.azurerm_virtual_network.hub_region1.id
  spoke_vnet_id = module.sb_spk_region1.vnet_id
  spoke_prefix = "sb"
  dns_zone_name = module.idk_shared_sql_dns_zone.dns_zone_name
  location = var.region1_loc
}

module "sb_sql_dns_zone_link_region2"{
  providers = {azurerm = azurerm.connectivity}
  source = "../../../../modules/private_dns/link_individual_spk"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  service_name = "sql"
  hub_vnet_id = data.azurerm_virtual_network.hub_region2.id
  spoke_vnet_id = module.sb_spk_region2.vnet_id
  spoke_prefix = "sb"
  dns_zone_name = module.idk_shared_sql_dns_zone.dns_zone_name
  location = var.region2_loc
}

resource "azurerm_route_table" "LandingZone-Region1" {
  provider = azurerm.landingzone
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

resource "azurerm_route_table" "LandingZone-Region2" {
  provider = azurerm.landingzone
  name                          = "RT-${var.lz_spk_rg_prefix}-${var.region2_loc}"
  location                      = azurerm_resource_group.lz_spk_region2.location
  resource_group_name           = azurerm_resource_group.lz_spk_region2.name

  route {
    name           = "Route-${var.lz_spk_rg_prefix}-${var.region2_loc}-HubNva"
    address_prefix = "10.0.0.0/8"
    next_hop_in_ip_address = var.dns_nva2_private_ip_addr
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_route_table" "SandBox-Region1" {
  provider = azurerm.landingzone
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
resource "azurerm_route_table" "SandBox-Region2" {
  provider = azurerm.landingzone
  name                          = "RT-${var.sb_spk_rg_prefix}-${var.region2_loc}"
  location                      = azurerm_resource_group.sb_spk_region2.location
  resource_group_name           = azurerm_resource_group.sb_spk_region2.name

  route {
    name           = "Route-${var.sb_spk_rg_prefix}-${var.region2_loc}-HubNva"
    address_prefix = "10.0.0.0/8"
    next_hop_in_ip_address = var.dns_nva2_private_ip_addr
    next_hop_type  = "VirtualAppliance"
  }

  tags = {
    environment = "Production"
  }
}