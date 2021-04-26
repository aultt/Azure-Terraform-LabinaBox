
resource "azurerm_policy_assignment" "azurefoundations" {
    name = "CIS-Azure-Foundations"
    scope = var.policy_scope
    policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1a5bb27d-173f-493e-9568-eb56638dde4d"
    description = "CIS Microsoft Azure Foundations Benchmark v1.1.0"
    display_name = "CIS Microsoft Azure Foundations Benchmark v1.1.0"
}



