resource "azurerm_automation_dsc_configuration" "dsc_dns1" {
  name                    = "Dns1config"
  automation_account_name = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name


  content_embedded = <<CONFIG
configuration Dns1config
{

Import-DSCResource -ModuleName StorageDsc
Import-DSCResource -ModuleName ActiveDirectoryDsc
Import-DSCResource -ModuleName ComputerManagementDsc
Import-DSCResource -ModuleName xTimeZone
Import-DSCResource -ModuleName xDnsServer
Import-DSCResource -ModuleName NetworkingDsc

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

  Registry EnableIpRouter
  {
      Ensure = "Present"
      key = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\IpEnableRouter"
      ValueName = "1"
  }

  NetIPInterface EnableForwarding
  {
      InterfaceAlias = '*'
      AddressFamily  = 'IPv4'
      Forwarding    = 'Enabled'
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

   WaitForADDomain WaitForestAvailability
    {
        DomainName = "${var.domain_name}"
        Credential = $domain_login
        WaitForValidCredentials = $true
        WaitTimeout = 2400
    }

   Computer DomainJoin
   {
       Name       = "${var.dns1_name}"
       DomainName = "${var.domain_name}"
       Credential = $domain_login
       
       DependsOn = '[WaitForADDomain]WaitForestAvailability','[NetIPInterface]EnableForwarding','[Registry]EnableIpRouter'
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
       MasterServers    = @("${var.dc1_private_ip_addr}","${var.dc2_private_ip_addr}","${var.domain_ip}")
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
   
   xDnsServerConditionalForwarder 'publicvault'
   {
       Name             = 'vault.azure.net'
       MasterServers    = '168.63.129.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }

   xDnsServerConditionalForwarder 'blob'
   {
       Name             = 'blob.core.windows.net'
       MasterServers    = '168.63.129.16'
       ReplicationScope = 'None'
      DependsOn = '[WindowsFeature]DNS'
   }
  xDnsServerConditionalForwarder 'publicdatabase'
   {
       Name             = 'database.windows.net'
       MasterServers    = '168.63.129.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
   xDnsServerConditionalForwarder 'privatedatabase'
   {
       Name             = 'privatelink.database.windows.net'
       MasterServers    = '168.63.129.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
   xDnsServerConditionalForwarder 'privatevault'
   {
       Name             = 'privatelink.vaultcore.azure.net'
       MasterServers    = '168.63.129.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
   
   xDnsServerConditionalForwarder 'privatestorage'
   {
       Name             = 'privatelink.blob.core.windows.net'
       MasterServers    = '168.63.129.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
   
   xDnsServerConditionalForwarder 'privateweb'
   {
       Name             = 'privatelink.azurewebsites.azure.net'
       MasterServers    = '168.63.129.16'
       ReplicationScope = 'None'
       DependsOn = '[WindowsFeature]DNS'
   }
}
}
CONFIG
}
