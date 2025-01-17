terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
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

provider "azapi" {
    subscription_id = var.poc_subscription_id
}

provider "azurerm" {
    features {} 
    alias = "poc"
    subscription_id = var.poc_subscription_id
}
data "azurerm_subscription" "poc" {
  subscription_id = var.poc_subscription_id
}

data "azurerm_resource_group" "dataRg" {
  name = var.resource_group_name
}


data "azurerm_subnet" "lz_subnet" {
  provider = azurerm.poc
  name                 = var.lz_subnet_name
  resource_group_name  = var.lz_network_rg
  virtual_network_name = var.lz_network_name
}
resource "azurerm_private_endpoint" "fabric-endpoint" {
  name                = "fabric-${var.location}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.lz_subnet.id

  private_service_connection {
    name                           = "fabric-private-link-connection"
    private_connection_resource_id = azapi_resource.private_fabric.id
    is_manual_connection           = false
    subresource_names              = ["tenant"]
  }

  private_dns_zone_group {
    name                          = var.dns_zone_group
    private_dns_zone_ids          = [ azurerm_private_dns_zone.privatelink-analysis-windows-net.id,
        azurerm_private_dns_zone.privatelink-pbidedicated-windows-net.id,
        azurerm_private_dns_zone.privatelink-prod-powerquery-microsoft-com.id 
    ]
  }      
}

resource "azapi_resource" "private_fabric" {
  parent_id = data.azurerm_resource_group.dataRg.id
  type = "Microsoft.PowerBI/privateLinkServicesForPowerBI@2020-06-01"
  name = var.name
  location = var.location
  body = {
    properties ={
      tenantId = data.azurerm_subscription.poc.tenant_id
    }
  }
}
resource "azurerm_private_dns_zone" "privatelink-analysis-windows-net" {
  name                = "privatelink.analysis.windows.net"
  resource_group_name = var.hub_resource_group
}

resource "azurerm_private_dns_zone" "privatelink-pbidedicated-windows-net" {
  name                = "privatelink.pbidedicated.windows.net"
  resource_group_name = var.hub_resource_group
}
resource "azurerm_private_dns_zone" "privatelink-prod-powerquery-microsoft-com" {
  name                = "privatelink.prod.powerquery.microsoft.com"
  resource_group_name = var.hub_resource_group
}
## STEP 1:  enable Private Endpoints for Fabric in GUI
## STEP 2: Execute Terraform to attache PE to Fabric
## STEP 3: Create Azure DNS Private Resolver
## STEP 4: Validate connectivity from On-Prem
## STEP 5: Turn off Public access to Fabric in GUI
