# NIC for vm

resource "azurerm_network_interface" "vm" { 
    name                 = "${var.vm_name}-nic"
    location             = var.location
    resource_group_name  = var.resource_group_name
    enable_ip_forwarding = var.nic_forwarding
    enable_accelerated_networking = var.enable_accelerated_networking
    ip_configuration { 
        name                          = "configuration"
        subnet_id                     = var.subnet_id 
        private_ip_address_allocation = "Static"
        private_ip_address            = var.vm_private_ip_addr
        
    }
}
resource "tls_private_key" "oracle_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size               = var.vm_size
  admin_username = var.vm_admin_username
  network_interface_ids = [
        azurerm_network_interface.vm.id
    ]
  admin_ssh_key {
    username = var.vm_admin_username
    public_key = tls_private_key.oracle_ssh.public_key_openssh
  }
 
  os_disk{
    caching = "ReadWrite"
    storage_account_type = var.os_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku
    version   = var.vm_version
 }
 
  timeouts {
      create = "60m"
      delete = "2h"
  }
}

resource "azurerm_virtual_machine_extension" "vm1extension" {
  name                 = var.vm_name
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "fileUris":[
          "https://raw.githubusercontent.com/aultt/Azure-Terraform-LabinaBox/main/AppZone/Hub_Spoke/Single_Region/Oracle_Single/bash/oracle-setup-ansible.sh",
          "https://raw.githubusercontent.com/aultt/Azure-Terraform-LabinaBox/main/AppZone/Hub_Spoke/Single_Region/Oracle_Single/ansible/Configure-ASM-server.yml",
          "https://raw.githubusercontent.com/aultt/Azure-Terraform-LabinaBox/main/AppZone/Hub_Spoke/Single_Region/Oracle_Single/files/dbca19.rsp",
          "https://raw.githubusercontent.com/aultt/Azure-Terraform-LabinaBox/main/AppZone/Hub_Spoke/Single_Region/Oracle_Single/files/gridsetup.rsp"
        ]
        
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": ". ./oracle-setup-ansible.sh -g '${var.grid_password}' -o '${var.oracle_password}' -r '${var.root_password}' -w '${var.swap_size}' -u '${var.grid_storage_url}' -y '${var.ora_sys_password}' -s '${var.ora_system_password}' -m '${var.ora_monitor_password}' -d '${var.oracle_database_name}'"
    }
PROTECTED_SETTINGS
}

