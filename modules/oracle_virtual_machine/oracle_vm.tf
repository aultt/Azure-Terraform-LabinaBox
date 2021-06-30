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

#resource "azurerm_managed_disk" "asm_disks" {
#    count = var.asm_disk_count
#    name                 = "${var.vm_name}-asm-disk${count.index}"  
#    #name                 = "${var.vm_name}-asm-disk"  
#    location             = var.location
#    resource_group_name  = var.resource_group_name
#    storage_account_type = var.storage_account_type
#    create_option        = "Empty"
#    disk_size_gb         = var.asm_disk_size_gb
#}

#resource "azurerm_virtual_machine_data_disk_attachment" "asm_disks_attachment" {
#  count = var.asm_disk_count
#  managed_disk_id    = azurerm_managed_disk.asm_disks[count.index].id
#  #managed_disk_id    = azurerm_managed_disk.asm_disks.id
#  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
#  lun = count.index+10
#  #lun = 10
#  caching            = "ReadWrite"
#}

#resource "azurerm_managed_disk" "data_disks" {
#    count = var.data_disk_count
#    name                 = "${var.vm_name}-data-disk-${count.index}"  
#    location             = var.location
#    resource_group_name  = var.resource_group_name
#    storage_account_type = var.storage_account_type
#    create_option        = "Empty"
#    disk_size_gb         = var.data_disk_size_gb
#}
#
#resource "azurerm_virtual_machine_data_disk_attachment" "data_disks_attachment" {
#  count = var.data_disk_count
#  managed_disk_id    = azurerm_managed_disk.data_disks[count.index].id
#  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
#  lun = count.index+20
#  caching            = "ReadOnly"
#}

#resource "azurerm_managed_disk" "redo_disks" {
#    count = var.redo_disk_count
#    name                 = "${var.vm_name}-redo-disk-${count.index}"  
#    #name                 = "${var.vm_name}-redo-disk"
#    location             = var.location
#    resource_group_name  = var.resource_group_name
#    storage_account_type = var.storage_account_type
#    create_option        = "Empty"
#    disk_size_gb         = var.redo_disk_size_gb
#}
#
#resource "azurerm_virtual_machine_data_disk_attachment" "redo_disks_attachment" {
#  count = var.redo_disk_count
#  managed_disk_id    = azurerm_managed_disk.redo_disks[count.index].id
#  #managed_disk_id    = azurerm_managed_disk.redo_disks.id
#  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
#  lun = count.index+60
#  #lun =30
#  caching            = "ReadWrite"
#}

resource "azurerm_virtual_machine_extension" "vm1extension" {
  name                 = var.vm_name
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "fileUris":["https://raw.githubusercontent.com/aultt/Azure-Terraform-LabinaBox/main/AppZone/Hub_Spoke/Single_Region/Oracle_Single/bash/oracle-setup-ansible.sh"]
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": ". ./oracle-setup-ansible.sh"
    }
PROTECTED_SETTINGS
}

