#Login-AzureRmAccount

$myvnet = Get-AzureRmVirtualNetwork -Name "lnkvnet" -ResourceGroupName "laniakea.net"

$frontEnd = $myVnet.Subnets|?{$_.Name -eq 'lnkvnet1'}
$myNic1 = New-AzureRmNetworkInterface -ResourceGroupName "laniakea.net" `
    -Name "lnkn3nic1" `
    -Location "CentralUs" `
    -SubnetId $frontEnd.Id

$backEnd = $myVnet.Subnets|?{$_.Name -eq 'lnkvnet2'}
$myNic2 = New-AzureRmNetworkInterface -ResourceGroupName "laniakea.net" `
    -Name "lnkn3nic2" `
    -Location "CentralUS" `
    -SubnetId $backEnd.Id

#$cred = Get-Credential

    $vmConfig = New-AzureRmVMConfig -VMName "lnkn3" -VMSize "Standard_A2_v2" -AvailabilitySetId "/subscriptions/5ab28d9e-f464-45d8-adeb-c7a0e8c678f6/resourceGroups/laniakea.net/providers/Microsoft.Compute/availabilitySets/lnkavailabilitysetcluster2"

    $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig `
    -Windows `
    -ComputerName "lnkn3" `
    -Credential $cred `
    -ProvisionVMAgent `
    -EnableAutoUpdate
$vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig `
    -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" `
    -Skus "2012-R2-Datacenter" `
    -Version "latest"


$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $myNic1.Id -Primary
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $myNic2.Id

New-AzureRmVM -VM $vmConfig -ResourceGroupName "laniakea.net" -Location "CentralUs"