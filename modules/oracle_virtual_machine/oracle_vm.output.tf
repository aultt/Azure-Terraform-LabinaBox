output "tls_private_key" { value = tls_private_key.oracle_ssh.private_key_pem }
output "vm_name" {value = azurerm_linux_virtual_machine.vm.name}