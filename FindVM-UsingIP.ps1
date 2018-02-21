(Get-AzureRmNetworkInterface | Where-Object {$_.IpConfigurations.PrivateIPAddress -eq "10.243.2.49" } ).VirtualMachine | Format-List
