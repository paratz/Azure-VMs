$VMs = Get-AzureVM 
foreach ($v in $VMs) { 
    $File = "C:\tmp\" + $v.Name + ".xml"
    Export-AzureVM -ServiceName $v.ServiceName -Name $v.Name -Path $File
}