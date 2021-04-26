resource "azurerm_automation_dsc_configuration" "dsc_dc2" {
  name                    = "DC2config"
  automation_account_name = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name


  content_embedded = <<CONFIG
configuration DC2config
{

Import-DSCResource -ModuleName StorageDsc
Import-DSCResource -ModuleName ActiveDirectoryDsc
Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DSCResource -ModuleName NetworkingDsc
Import-DSCResource -ModuleName ComputerManagementDsc
Import-DSCResource -ModuleName xTimeZone
Import-DSCResource -ModuleName xDnsServer

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
      FSFormat = 'NTFS'
      AllocationUnitSize = 64kb
    DependsOn="[WaitForDisk]Disk2"
  }

  LocalConfigurationManager
   {
       ConfigurationMode = 'ApplyAndAutoCorrect'
       RebootNodeIfNeeded = $true
       ActionAfterReboot = 'ContinueConfiguration'
       AllowModuleOverwrite = $true
   }
   
   File 'ADFiles'
   {
        Ensure = 'Present'
        DestinationPath = "F:\NTDS"
        Type = 'Directory'

        DependsOn = '[Disk]ADDataDisk2'
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

