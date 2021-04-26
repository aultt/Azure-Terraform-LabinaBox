$resource_group_name = 'svc-core-prod-rg'
$automation_account_name = 'auto-core-eastus-tamz'

Select-AzSubscription -Subscription Management

$devCompilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resource_group_name -AutomationAccountName $automation_account_name -ConfigurationName 'devConfig' 
while($null -eq $devCompilationjob.EndTime -and $null -eq $devCompilationjob.Exception)
{
    $devCompilationjob = $devCompilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$devCompilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any



$DC1Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resource_group_name -AutomationAccountName $automation_account_name -ConfigurationName 'DC1config'
while($null -eq $DC1Compilationjob.EndTime -and $null -eq $DC1Compilationjob.Exception)
{
    $DC1Compilationjob = $DC1Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$DC1Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any



$DC2Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resource_group_name -AutomationAccountName $automation_account_name -ConfigurationName 'DC2config'
while($null -eq $DC2Compilationjob.EndTime -and $null -eq $DC2Compilationjob.Exception)
{
    $DC2Compilationjob = $DC2Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$DC2Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any

$Dns1Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resource_group_name -AutomationAccountName $automation_account_name -ConfigurationName 'Dns1config'
while($null -eq $Dns1Compilationjob.EndTime -and $null -eq $Dns1Compilationjob.Exception)
{
    $Dns1Compilationjob = $Dns1Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$Dns1Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any

$Dns2Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resource_group_name -AutomationAccountName $automation_account_name -ConfigurationName 'Dns2config'
while($null -eq $Dns2Compilationjob.EndTime -and $null -eq $Dns2Compilationjob.Exception)
{
    $Dns2Compilationjob = $Dns2Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$Dns2Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any

