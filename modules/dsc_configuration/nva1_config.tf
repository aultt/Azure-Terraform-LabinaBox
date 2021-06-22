resource "azurerm_automation_dsc_configuration" "NVA1" {
  name                    = "NVA1config"
  automation_account_name = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name


  content_embedded = <<CONFIG
configuration NVA1config
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

   WindowsFeature 'RSAT-ADDS-Tools'
   {
       Ensure = 'Present'
       Name = 'RSAT-ADDS-Tools'
   }
}
}
CONFIG
}
