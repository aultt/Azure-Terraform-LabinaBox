resource "azurerm_policy_assignment" "auditvmdisks" {
    name = "audit-vm-manageddisks"
    scope = var.policy_scope
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
    description = "Shows all virtual machines not using managed disks"
    display_name = "Audit VMs without managed disks Assignment"
}
resource "azurerm_policy_assignment" "auditvmwithpendingreboot" {
    name = "WindowsPendingReboot"
    scope = var.policy_scope
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
    description = "Shows all virtual machines with a Pending Reboot"
    display_name = "Audit Vms with Pending Reboot"
}
resource "azurerm_policy_assignment" "deployguesconfigvm" {
    name = "Deploy-Guest-PreReq-VMs"
    scope = var.policy_scope
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
    description = "Deploy prerequisites to enable Guest Configuration policies on virtual machines"
    display_name = "Deploy prerequisites to enable Guest Configuration policies on virtual machines"
}
resource "azurerm_policy_assignment" "azurebackupvm" {
    name = "Audit-Azure-Backup-VMs"
    scope = var.policy_scope
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/013e242c-8828-4970-87b3-ab247555486d"
    description = "Azure Backup should be enabled for Virtual Machines"
    display_name = "Azure Backup should be enabled for Virtual Machines"
}
