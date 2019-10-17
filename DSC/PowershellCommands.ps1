Select-AzSubscription -Subscription cbca3a93-a647-464b-b7de-8a3ab84c2a75

Import-AzAutomationDscConfiguration -SourcePath 'C:\GitHub\Azure-VMs\DSC\LinuxSoftwareBase.ps1' -ResourceGroupName 'management-prod-rg'  -AutomationAccountName 'aa-prod-management' -Published

Start-AzAutomationDscCompilationJob -ConfigurationName 'LinuxSoftwareBasev1' -ResourceGroupName 'management-prod-rg' -AutomationAccountName 'aa-prod-management'