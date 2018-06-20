$SubFabrikam = "cfcb919c-c5a1-4bee-8f4a-5ccaeccc0787"
$SubCentralIT = "cbca3a93-a647-464b-b7de-8a3ab84c2a75"

Select-AzureRmSubscription -subscriptionid $SubFabrikam
$VnetSpokeName = "internalVNET"
$VnetSpokeRG = "fabrikam.com.ar"
$vNetB=Get-AzureRmVirtualNetwork -Name $VnetSpokeName -ResourceGroupName $VnetSpokeRG

Select-AzureRmSubscription -subscriptionid $SubCentralIT
$VnetHubName = "paratz-hub-vnet"
$VnetHubRG = "network-hub-rg"
$vNetA=Get-AzureRmVirtualNetwork -Name $VnetHubName -ResourceGroupName $VnetHubRG

Add-AzureRmVirtualNetworkPeering `
  -Name 'hub-to-fabrikamvnet-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId $VnetB.Id -AllowGatewayTransit

Select-AzureRmSubscription -subscriptionid $SubFabrikam
 
Add-AzureRmVirtualNetworkPeering `
  -Name 'fabrikamvnet-to-hub-peering' `
  -VirtualNetwork $vNetB `
  -RemoteVirtualNetworkId $Vneta.Id -UseRemoteGateways
