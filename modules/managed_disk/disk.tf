data "azurerm_virtual_machine" "vm" {
  name = var.vm_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_managed_disk" "disks_group" {
    count = var.disk_count
    name                 = "${data.azurerm_virtual_machine.vm.name}-${var.disk_prefix}-${count.index}"  
    location             = var.location
    resource_group_name  = data.azurerm_virtual_machine.vm.resource_group_name
    storage_account_type = var.storage_account_type
    create_option        = "Empty"
    disk_size_gb         = var.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "Disk_Attachment" {
  count = var.disk_count
  managed_disk_id    = azurerm_managed_disk.disks_group[count.index].id
  virtual_machine_id = data.azurerm_virtual_machine.vm.id
  lun = count.index+var.vm_lun_start
  caching            = var.disk_cache_type 
}