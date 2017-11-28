#Script create by sebastid

Login-AzureRmAccount

$vms =Get-AzureRmVM -ResourceGroupName fabrikam.com.ar -Name adtrusttest

$nics = $vms.networkprofile

# on this foreach we take the networkprofile and then we are using the split property so we can parse the name of the NIC, right after that
# we are modifying the ipconfiguration.publicipaddress to "" that means none
foreach ($vm in $vms)
{
$nics = $vm.networkprofile
$nicname = $nics.networkinterfaces.id.split("/")[8]
$nicobject = Get-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $vm.resourcegroupname

$nicobject.IpConfigurations.PublicIpAddress.Id = ""
$nicobject | Set-AzureRmNetworkInterface
}
