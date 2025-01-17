terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.52"
    }
  }
}

provider "azurerm" {
    resource_provider_registrations = "none"
    subscription_id = var.poc_subscription_id
    features {} 
} 

provider "azurerm" {
    features {} 
    alias = "poc"
    subscription_id = var.poc_subscription_id
}
data "azurerm_virtual_network" "hub_region1" {
  provider = azurerm.poc
  name                = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_key_vault" "keyvault_region1" {
  name = "kv-${var.corp_prefix}-${var.region1_loc}"
  resource_group_name =  data.azurerm_virtual_network.id_spk_region1.resource_group_name
}

data "azurerm_subnet" "hub_default_subnet_region1" {
  provider = azurerm.poc
  name                 = "default"
  resource_group_name  = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.hub_vnet_name_prefix}-${var.region1_loc}"

}
data "azurerm_subnet" "id_spk_region1_infra_subnet_Region1" {
  provider = azurerm.poc
  name                 = var.id_spk_region1_infra_subnet_name
  resource_group_name  = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.id_spk_vnet_name_prefix}-${var.region1_loc}"

}
data "azurerm_virtual_network" "id_spk_region1" {
  provider = azurerm.poc
  name                = "${var.id_spk_vnet_name_prefix}-${var.region1_loc}"
  resource_group_name = "${var.id_spk_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_subnet" "jumphost_subnet_Region1" {
  provider = azurerm.poc
  name                 = var.jump_host_subnet_name
  resource_group_name  = "${var.hub_rg_prefix}-${var.region1_loc}-rg"
  virtual_network_name = "${var.hub_vnet_name_prefix}-${var.region1_loc}"
}
data "azurerm_automation_account" "dsc" {
  provider = azurerm.poc
  name                = "auto-core-${var.region1_loc}-${var.corp_prefix}"
  resource_group_name = "${var.svc_rg_prefix}-${var.region1_loc}-rg"
}

data "azurerm_key_vault_secret" "local-admin-password" {
  name = "local-admin-password"
  key_vault_id = data.azurerm_key_vault.keyvault_region1.id
}
output "local-admin-password" {
  value = "${data.azurerm_key_vault_secret.local-admin-password.value}"
  sensitive = true
}

## Add Subnet to Hub for outbound traffic from the private Dns resolver
resource "azurerm_subnet" "outbound-pdns" {
  name = var.outbound_subnet_name
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.hub_region1.name
  address_prefixes = [var.outbound_subnet_addr]
  
  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

## Add Subnet to Hub for inbound traffic from the private DNS resolver
resource "azurerm_subnet" "inbound-pdns" {
  name = var.inbound_subnet_name
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.hub_region1.name
  address_prefixes = [var.inbound_subnet_addr]
  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

#Create Endpoint for outbound traffic from Private DNS Resolver
resource "azurerm_private_dns_resolver_outbound_endpoint" "outbound_endpoint" {
  name = "${var.region1_loc}outboundEP"
  private_dns_resolver_id = azurerm_private_dns_resolver.private_dns_resolver.id
  location = var.region1_loc
  subnet_id = azurerm_subnet.outbound-pdns.id
}

#Create Endpoint for Inboudn traffic to Private DNS Resolver
resource "azurerm_private_dns_resolver_inbound_endpoint" "inbound_endpoint" {
  name = "${var.region1_loc}inboundEP"
  private_dns_resolver_id = azurerm_private_dns_resolver.private_dns_resolver.id
  location = var.region1_loc
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id = azurerm_subnet.inbound-pdns.id
  }
}

resource "azurerm_private_dns_resolver" "private_dns_resolver" {
  name                = "dnsPrivateResolver"
  resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
  location            = data.azurerm_virtual_network.hub_region1.location
  virtual_network_id  = data.azurerm_virtual_network.hub_region1.id
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "forwardingRS" {
  name                                       = "${var.corp_prefix}-ruleset"
  resource_group_name                        = data.azurerm_virtual_network.hub_region1.resource_group_name
  location                                   = data.azurerm_virtual_network.hub_region1.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.outbound_endpoint.id]
}

resource "azurerm_private_dns_resolver_forwarding_rule" "onprem" {
  name                      = "onpremrule"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.forwardingRS.id
  domain_name               = var.onprem_domain_name
  enabled                   = true
  target_dns_servers {
    ip_address = var.onprem_target_dns_server_ip
    port       = 53
  }
}

resource "azurerm_private_dns_resolver_virtual_network_link" "linktoHub" {
  name                      = "${data.azurerm_virtual_network.hub_region1.name}-link"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.forwardingRS.id
  virtual_network_id        = data.azurerm_virtual_network.hub_region1.id
}

#module "dev_vm" { 
#    providers = { azurerm = azurerm
#      azurerm.poc = azurerm.poc }
#    source = "../../../../modules/virtual_machine"
#    resource_group_name = data.azurerm_virtual_network.hub_region1.resource_group_name
#    location = data.azurerm_virtual_network.hub_region1.location
#    vm_name = "aedev001"
#    vm_private_ip_addr = var.jump_host_private_ip_addr
#    vm_size = var.jump_host_vm_size
#    vm_admin_username  = var.local_admin_username
#    vm_admin_password  = data.azurerm_key_vault_secret.local-admin-password.value
#    subnet_id = data.azurerm_subnet.jumphost_subnet_Region1.id
#    storage_account_type = var.jump_host_storage_account_type
#    data_disk_size_gb = var.jump_host_data_disk_size
#    dsc_config                     = "devConfigNoDomain.localhost"
#    dsc_key                        = data.azurerm_automation_account.dsc.primary_key
#    dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
#    workspace_id  = data.azurerm_automation_account.dsc.id             
#    workspace_key = data.azurerm_automation_account.dsc.primary_key
#    publisher = "MicrosoftWindowsDesktop"
#    offer = "Windows-11"
#    sku = "win11-24h2-pro"
#}