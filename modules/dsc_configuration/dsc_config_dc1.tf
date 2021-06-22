resource "azurerm_automation_module" "ad" {
  name                    = "ActiveDirectoryDsc"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/activedirectorydsc.6.0.1.nupkg"
  }
}
resource "azurerm_automation_module" "storage" {
  name                    = "StorageDsc"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/storagedsc.5.0.1.nupkg"
  }
}
resource "azurerm_automation_module" "networking" {
  name                    = "NetworkingDsc"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/networkingdsc.8.2.0.nupkg"
  }
}
resource "azurerm_automation_module" "xtimezone" {
  name                    = "xtimezone"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xtimezone.1.8.0.nupkg"
  }
}
resource "azurerm_automation_module" "xdnsserver" {
  name                    = "xdnsserver"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xdnsserver.2.0.0.nupkg"
  }
}
resource "azurerm_automation_credential" "domain_admin" {
  name                    = "domain_admin"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  username                = var.domain_user
  password                = var.domain_admin_password
}

resource "azurerm_automation_dsc_configuration" "dsc_dc1" {
  name                    = "DC1config"
  automation_account_name = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name


  content_embedded = <<CONFIG
configuration DC1config
{

Import-DSCResource -ModuleName StorageDsc
Import-DSCResource -ModuleName ActiveDirectoryDsc
Import-DSCResource -ModuleName NetworkingDsc
Import-DSCResource -ModuleName xTimeZone
Import-DSCResource -ModuleName ComputerManagementDsc

$domain_login = Get-AutomationPSCredential -Name "domain_admin"

Node "localhost"
{ 
  
  xTimeZone SetTimeZone
  {
      IsSingleInstance = 'Yes'
      TimeZone         = 'Eastern Standard Time'
  }

  WaitforDisk Disk2
  {
        DiskId = "2"
        RetryIntervalSec = 30
        RetryCount = 20
  }
  Disk ADDataDisk2
  {
      DiskId = "2"
      DriveLetter = "F"
      FSFormat ='NTFS'
      AllocationUnitSize = 64kb
    DependsOn="[WaitForDisk]Disk2"
  }

  File 'ADFiles'
  {
     Ensure = 'Present'
     DestinationPath = "F:\NTDS"
     Type = 'Directory'

     DependsOn = '[Disk]ADDataDisk2'
  }

  LocalConfigurationManager
   {
       ConfigurationMode = 'ApplyAndAutoCorrect'
       RebootNodeIfNeeded = $true
       ActionAfterReboot = 'ContinueConfiguration'
       AllowModuleOverwrite = $true
   }

   WindowsFeature DNS_RSAT
   { 
       Ensure = "Present" 
       Name = "RSAT-DNS-Server"
    }

   WindowsFeature ADDS_Install 
   { 
       Ensure = 'Present' 
       Name = 'AD-Domain-Services' 
   } 

   WindowsFeature RSAT_AD_AdminCenter 
   {
       Ensure = 'Present'
       Name   = 'RSAT-AD-AdminCenter'
   }

   WindowsFeature RSAT_ADDS 
   {
       Ensure = 'Present'
       Name   = 'RSAT-ADDS'
   }

   WindowsFeature RSAT_AD_PowerShell 
   {
       Ensure = 'Present'
       Name   = 'RSAT-AD-PowerShell'
   }

   WindowsFeature RSAT_AD_Tools 
   {
       Ensure = 'Present'
       Name   = 'RSAT-AD-Tools'
   }

   WindowsFeature RSAT_Role_Tools 
   {
       Ensure = 'Present'
       Name   = 'RSAT-Role-Tools'
   }

   WaitForADDomain WaitForestAvailability
    {
        DomainName = "${var.domain_name}"
        Credential = $domain_login
        WaitForValidCredentials = $true
        WaitTimeout = 600
        DependsOn  = '[WindowsFeature]RSAT_AD_PowerShell'
    }

   ADDomainController AddDC
    { 
        DomainName = "${var.domain_name}"
        Credential = $domain_login
        SafemodeAdministratorPassword = $domain_login
        DatabasePath = "F:\NTDS"
        LogPath =  "F:\NTDS"
        SysvolPath = "F:\SYSVOL"
        DependsOn = '[WaitForADDomain]WaitForestAvailability'
    }

}
}
CONFIG
}


variable domain_name {}
variable domain_user {}
variable admin_password {}
variable domain_NetbiosName {}
variable admin_username {}
variable domain_login {}
variable "domain_admin_password" {}
variable "automation_account_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "domain_ip" {}
variable "jump_host_name" {}
variable "dns1_name" {}
variable "dns2_name" {}
variable "dc2_private_ip_addr"{}
variable "dc1_private_ip_addr" {}