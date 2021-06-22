#resource "azurerm_automation_module" "choco_nodc" {
#  name                    = "cchoco"
#  resource_group_name     = var.resource_group_name
#  automation_account_name = var.automation_account_name
#
#  module_link {
#    uri = "https://psg-prod-eastus.azureedge.net/packages/cchoco.2.5.0.nupkg"
#  }
#}

resource "azurerm_automation_dsc_configuration" "dsc_dev_nodc" {
  name                    = "devConfigNoDomain"
  automation_account_name = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  content_embedded = <<CONFIG
configuration devConfigNoDomain
{
Import-DSCResource -ModuleName StorageDsc
Import-DSCResource -ModuleName cChoco
Import-DSCResource -ModuleName ActiveDirectoryDsc
Import-DSCResource -ModuleName ComputerManagementDsc
Import-DSCResource -ModuleName xTimeZone
$domain_login = Get-AutomationPSCredential -Name "domain_admin"

Node "localhost"
{ 
  LocalConfigurationManager
   {
       ConfigurationMode = 'ApplyAndAutoCorrect'
       RebootNodeIfNeeded = $true
       ActionAfterReboot = 'ContinueConfiguration'
       AllowModuleOverwrite = $true
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
  xTimeZone SetTimeZone
  {
      IsSingleInstance = 'Yes'
      TimeZone         = 'Eastern Standard Time'
  }
   PowerPlan 'HighPerf'
   {
     IsSingleInstance = 'Yes'
     Name             = 'High performance'
   }

   cChocoInstaller installChoco
   {
     InstallDir = "c:\choco"
   }
   cChocoPackageInstaller installAzureStorageExp
   {
       Name                 = 'microsoftazurestorageexplorer'
       Ensure               = 'Present'
       DependsOn            = '[cChocoInstaller]installChoco'
   }
   cChocoPackageInstaller azcopy
   {
       Name                 = 'azcopy10'
       Ensure               = 'Present'
       DependsOn            = '[cChocoInstaller]installChoco'
   }
   cChocoPackageInstaller vscode
   {
       Name                 = 'vscode'
       Ensure               = 'Present'
       DependsOn            = '[cChocoInstaller]installChoco'
   }
   cChocoPackageInstaller vscodepowershell
   {
       Name                 = 'vscode-powershell'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]vscode'
   }
   cChocoPackageInstaller vscodeaccount
   {
       Name                 = 'azureaccount-vscode'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]vscode'
   }
   cChocoPackageInstaller vscodefunctions
   {
       Name                 = 'azurefunctions-vscode'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]vscode'
   }
}
}
CONFIG
}
