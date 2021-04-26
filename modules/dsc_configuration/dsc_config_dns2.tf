resource "azurerm_automation_dsc_configuration" "dsc_dns2" {
  name                    = "Dns2config"
  automation_account_name = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name


  content_embedded = <<CONFIG
configuration Dns2config
{

Import-DSCResource -ModuleName StorageDsc
Import-DSCResource -ModuleName ActiveDirectoryDsc
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

    WaitForADDomain WaitForestAvailability
    {
        DomainName = "${var.domain_name}"
        Credential = $domain_login
        WaitForValidCredentials = $true
        WaitTimeout = 2400

    }

   Computer DomainJoin
   {
       Name       = "${var.dns2_name}"
       DomainName = "${var.domain_name}"
       Credential = $domain_login

       DependsOn = '[WaitForADDomain]WaitForestAvailability'
   }
   
   WindowsFeature DNS_RSAT
   { 
       Ensure = "Present" 
       Name = "RSAT-DNS-Server"
    }
   WindowsFeature 'RSAT-ADDS-Tools'
   {
       Ensure = 'Present'
       Name = 'RSAT-ADDS-Tools'
   }
   
   WindowsFeature 'DNS'
   {
       Ensure = 'Present'
       Name = 'DNS'

       DependsOn = '[Computer]DomainJoin'
   }
   
   xDnsServerConditionalForwarder 'tamz'
   {
       Name             = "${var.domain_name}"
       MasterServers    = @('10.4.3.5','10.3.3.5','192.168.40.5')
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }

   xDnsServerConditionalForwarder 'blob'
   {
       Name             = 'blob.core.windows.net'
       MasterServers    = '168.63.125.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
  xDnsServerConditionalForwarder 'publicdatabase'
   {
       Name             = 'database.windows.net'
       MasterServers    = '168.63.125.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
   xDnsServerConditionalForwarder 'privatedatabase'
   {
       Name             = 'privatelink.database.windows.net'
       MasterServers    = '168.63.125.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
   xDnsServerConditionalForwarder 'privatevault'
   {
       Name             = 'privatelink.vaultcore.azure.net'
       MasterServers    = '168.63.125.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
}
}
CONFIG
}

