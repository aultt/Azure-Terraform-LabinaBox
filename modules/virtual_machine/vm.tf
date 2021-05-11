# NIC for vm

resource "azurerm_network_interface" "vm" { 
    name                              = "${var.vm_name}-nic"
    location                          = var.location
    resource_group_name               = var.resource_group_name
    enable_ip_forwarding          = var.nic_forwarding
    ip_configuration { 
        name                          = "configuration"
        subnet_id                     = var.subnet_id 
        private_ip_address_allocation = "Static"
        private_ip_address            = var.vm_private_ip_addr
        
    }
}

# Virtual Machine for vm 

resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [
        azurerm_network_interface.vm.id
    ]
  vm_size               = var.vm_size
 
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
 }
 
  storage_os_disk {
    name              = "${var.vm_name}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
 
  os_profile {
    computer_name      = var.vm_name
    admin_username     = var.vm_admin_username
    admin_password     = var.vm_admin_password
  }
 
  os_profile_windows_config {
    provision_vm_agent = true
  }
 
  timeouts {
      create = "60m"
      delete = "2h"
  }
}
resource "azurerm_managed_disk" "vm_data_disks" {
    name                 = "${var.vm_name}-disk-data-01"  
    location             = var.location
    resource_group_name  = var.resource_group_name
    storage_account_type = var.storage_account_type
    create_option        = "Empty"
    disk_size_gb         = var.data_disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disks_attachment" {
  managed_disk_id    = azurerm_managed_disk.vm_data_disks.id
  virtual_machine_id = azurerm_virtual_machine.vm.id
  lun = 10
  caching            = "None"
}

resource "azurerm_virtual_machine_extension" "dsc" {
  name                 = "DSConboard"
  virtual_machine_id   = azurerm_virtual_machine.vm.id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.80"  
  depends_on         = [azurerm_virtual_machine_data_disk_attachment.vm_data_disks_attachment]
  settings = <<SETTINGS
        {
            "WmfVersion": "latest",
            "Privacy": {
                "DataCollection": ""
            },
            "Properties": {
                "RegistrationKey": {
                  "UserName": "PLACEHOLDER_DONOTUSE",
                  "Password": "PrivateSettingsRef:registrationKeyPrivate"
                },
                "RegistrationUrl": "${var.dsc_endpoint}",
                "NodeConfigurationName": "${var.dsc_config}",
                "ConfigurationMode": "${var.dsc_mode}",
                "ConfigurationModeFrequencyMins": 15,
                "RefreshFrequencyMins": 30,
                "RebootNodeIfNeeded": true,
                "ActionAfterReboot": "continueConfiguration",
                "AllowModuleOverwrite": false
            }
        }
    SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Items": {
        "registrationKeyPrivate" : "${var.dsc_key}"
      }
    }
PROTECTED_SETTINGS
}

