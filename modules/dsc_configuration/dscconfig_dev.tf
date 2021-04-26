resource "azurerm_automation_module" "choco" {
  name                    = "cchoco"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/cchoco.2.5.0.nupkg"
  }
}

resource "azurerm_automation_dsc_configuration" "dsc_dev" {
  name                    = "devConfig"
  automation_account_name = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  content_embedded = <<CONFIG
configuration devConfig
{

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

   WaitForADDomain WaitForestAvailability
    {
        DomainName = "${var.domain_name}"
        Credential = $domain_login
        WaitForValidCredentials = $true
        WaitTimeout = 2400

    }
    
   Computer DomainJoin
   {
       Name       = "${var.jump_host_name}"
       DomainName = "${var.domain_name}"
       Credential = $domain_login

       DependsOn = '[WaitForADDomain]WaitForestAvailability'
   }

   cChocoInstaller installChoco
   {
     InstallDir = "c:\choco"
   }
   cChocoPackageInstaller installAzureDataStudio
   {
       Name                 = 'azure-data-studio'
       Ensure               = 'Present'
       DependsOn            = '[cChocoInstaller]installChoco'
   }
   cChocoPackageInstaller installAzureDataStudioExt1
   {
       Name                 = 'azure-data-studio-sql-server-admin-pack'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]installAzureDataStudio'
   }
   cChocoPackageInstaller installAzureDataStudioExt2
   {
       Name                 = 'azuredatastudio-powershell'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]installAzureDataStudio'
   }
   cChocoPackageInstaller azcopy
   {
       Name                 = 'azcoyp10'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]installAzureDataStudio'
   }
   cChocoPackageInstaller sqlservermgmtstudio
   {
       Name                 = 'sql-server-management-studio'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]installAzureDataStudio'
   }
   cChocoPackageInstaller vscode
   {
       Name                 = 'vscode'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]installAzureDataStudio'
   }
   cChocoPackageInstaller vscodemssql
   {
       Name                 = 'vscode-mssql'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]vscode'
   }
   cChocoPackageInstaller vscodepowershell
   {
       Name                 = 'vscode-powershell'
       Ensure               = 'Present'
       DependsOn            = '[cChocoPackageInstaller]vscode'
   }
}
}
CONFIG
}
