output "local_admin_username" {
    value = [for x in azurerm_virtual_machine.vm.os_profile : x.admin_username]
    sensitive = true
}

output "local_admin_password" {
    value = [for x in azurerm_virtual_machine.vm.os_profile : x.admin_password]
    sensitive = true
}