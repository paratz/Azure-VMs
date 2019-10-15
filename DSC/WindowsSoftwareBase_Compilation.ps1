$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = '*'
            PSDscAllowPlainTextPassword = $True
        },
        @{
            NodeName = 'localhost'
        }
    )
}

<#$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = '*'
            PSDscAllowPlainTextPassword = $True
        },
        @{
            NodeName = 'MyVM1'
        },
        @{
            NodeName = 'MyVM2'
        }
    )
}
#>


#Crear Job de Compilación
$compilationJob = Start-AzAutomationDscCompilationJob `
-ResourceGroupName 'management-prod-rg' `
-AutomationAccountName 'aa-prod-management' `
-ConfigurationName 'SoftwareDeBasev9' `
-ConfigurationData $ConfigData

#Monitorear Finalización del Job de Compilación
while(($compilationJob.EndTime –eq $null) -and ($compilationJob.Exception –eq $null))
{
    $compilationJob = $compilationJob | Get-AzAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}
$compilationJob


#Información Adicoinal:
# https://docs.microsoft.com/en-us/azure/automation/automation-dsc-compile#credential-assets
# https://buildingmydreamit.wordpress.com/2015/12/07/setup-phase-compiling-the-dsc-configuration/
# https://devblogs.microsoft.com/powershell/powershell-dsc-faq-sorting-out-certificates/
# https://blogs.technet.microsoft.com/ashleymcglone/2015/12/18/using-credentials-with-psdscallowplaintextpassword-and-psdscallowdomainuser-in-powershell-dsc-configuration-data/
# 