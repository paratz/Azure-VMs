$VMs = Get-AzureVM 
foreach ($v in $VMs) { 
    $File = "C:\tmp\" + $v.Name
    Export-AzureVM -ServiceName $v.ServiceName -Name $v.Name -Path $File
}