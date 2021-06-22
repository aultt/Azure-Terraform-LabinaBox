param($subscriptionId,$resourceGroupName, $automationAccountName)

Select-AzSubscription -Subscriptionid $subscriptionId

$devCompilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName 'devConfig' 
while($null -eq $devCompilationjob.EndTime -and $null -eq $devCompilationjob.Exception)
{
    $devCompilationjob = $devCompilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$devCompilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any



$DC1Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName 'DC1config'
while($null -eq $DC1Compilationjob.EndTime -and $null -eq $DC1Compilationjob.Exception)
{
    $DC1Compilationjob = $DC1Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$DC1Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any



$DC2Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName 'DC2config'
while($null -eq $DC2Compilationjob.EndTime -and $null -eq $DC2Compilationjob.Exception)
{
    $DC2Compilationjob = $DC2Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$DC2Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any

$Dns1Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName 'Dns1config'
while($null -eq $Dns1Compilationjob.EndTime -and $null -eq $Dns1Compilationjob.Exception)
{
    $Dns1Compilationjob = $Dns1Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$Dns1Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any

$Dns2Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName 'Dns2config'
while($null -eq $Dns2Compilationjob.EndTime -and $null -eq $Dns2Compilationjob.Exception)
{
    $Dns2Compilationjob = $Dns2Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$Dns2Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any

$Nva1Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName 'NVA1config'
while($null -eq $Nva1Compilationjob.EndTime -and $null -eq $Nva1Compilationjob.Exception)
{
    $Nva1Compilationjob = $Nva1Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$Nva1Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any

$Dev2Compilationjob=Start-AzAutomationDscCompilationJob -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName 'devConfigNoDomain'
while($null -eq $Dev2Compilationjob.EndTime -and $null -eq $Dev2Compilationjob.Exception)
{
    $Dev2Compilationjob = $Dev2Compilationjob| Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$Dev2Compilationjob | Get-AzAutomationDscCompilationJobOutput –Stream Any
