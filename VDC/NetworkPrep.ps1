## creacion de VNET (Hub\Produccion\Desarrollo\Certificacion)

#Variables Subscription
$subprod = "922a86de-0f41-4bb1-b1cb-4ab1fce2e718"
$subdesa = "d5aae4c2-2452-4174-a138-fcec19d0bc75"
$subhub = "03e480f1-3056-4b1d-9ea9-55a152f0d138"
$subcert = "0c6b7e18-5699-41e7-87bc-2eb6ef2c45c4"

$VnetProd = "10.72.48.0/21"
$VnetProdRG = "network-produccion-rg"
$VnetHub = "10.72.78.0/23"
$VnetHubRG = "network-hub-rg"
$VnetDesa = "10.72.56.0/21"
$VnetDesaRG = "network-desarrollo-rg"
$VnetCert = "10.72.64.0/21"
$VnetCertRG = "network-certificacion-rg"
$location = "eastus2"

#Crear red de producción
Select-AzureRmSubscription -subscriptionid $subprod
New-AzureRmResourceGroup -Name $VnetProdRG
New-AzureRmVirtualNetwork -ResourceGroupName $VnetProdRG -Name produccion-vnet -AddressPrefix $VnetProd -Location $location

#Crear Red de Desa

Select-AzureRmSubscription -subscriptionid $subdesa
New-AzureRmResourceGroup -name $VnetdesaRG -Location $location
New-AzureRmVirtualNetwork -ResourceGroupName $VnetDesaRG -Name desarrollo-vnet -AddressPrefix $VnetDesa -Location $location

#Crear Red HUB
Select-AzureRmSubscription -subscriptionid $subhub
New-AzureRmResourceGroup -name $VnethubRG -Location $location
New-AzureRmVirtualNetwork -ResourceGroupName $VnethubRG -Name hub-vnet -AddressPrefix $Vnethub -Location $location


#crear Red Certificacion
Select-AzureRmSubscription -subscriptionid $subcert
New-AzureRmResourceGroup -name $VnetcertRG -Location $location
New-AzureRmVirtualNetwork -ResourceGroupName $VnetcertRG -Name certificacion-vnet -AddressPrefix $Vnetcert -Location $location


######### Peering # 

$subprod = "922a86de-0f41-4bb1-b1cb-4ab1fce2e718"
$subdesa = "d5aae4c2-2452-4174-a138-fcec19d0bc75"
$subhub = "03e480f1-3056-4b1d-9ea9-55a152f0d138"
$subcert = "0c6b7e18-5699-41e7-87bc-2eb6ef2c45c4"

$VnetProd = "10.72.48.0/21"
$VnetProdRG = "network-produccion-rg"
$VnetHub = "10.72.78.0/23"
$VnetHubRG = "network-hub-rg"
$VnetDesa = "10.72.56.0/21"
$VnetDesaRG = "network-desarrollo-rg"
$VnetCert = "10.72.64.0/21"
$VnetCertRG = "network-certificacion-rg"
$location = "eastus2"


### En el VNET Peering correspondiente a la red del HUB se usa la opcion -allowgatewaytransit y en la red de destino se usa el -UseRemoteGateways
### Hub to Prod
Select-AzureRmSubscription -subscriptionid $subhub
$vNetA=Get-AzureRmVirtualNetwork -Name hub-vnet -ResourceGroupName $VnetHubRG
Add-AzureRmVirtualNetworkPeering `
  -Name 'hub-to-produccion-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId "/subscriptions/922a86de-0f41-4bb1-b1cb-4ab1fce2e718/resourceGroups/network-produccion-rg/providers/Microsoft.Network/virtualNetworks/produccion-vnet" -AllowGatewayTransit



Select-AzureRmSubscription -subscriptionid $subprod
$vNetA=Get-AzureRmVirtualNetwork -Name produccion-vnet -ResourceGroupName $VnetProdRG
Add-AzureRmVirtualNetworkPeering `
  -Name 'produccion-to-hub-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId "/subscriptions/03e480f1-3056-4b1d-9ea9-55a152f0d138/resourceGroups/network-hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet" -UseRemoteGateways



##### Configuracion HUB - DESA
$subprod = "922a86de-0f41-4bb1-b1cb-4ab1fce2e718"
$subdesa = "d5aae4c2-2452-4174-a138-fcec19d0bc75"
$subhub = "03e480f1-3056-4b1d-9ea9-55a152f0d138"
$subcert = "0c6b7e18-5699-41e7-87bc-2eb6ef2c45c4"
$VnetDesaRG = "network-desarrollo-rg"


Select-AzureRmSubscription -subscriptionid $subhub
$vNetA=Get-AzureRmVirtualNetwork -Name hub-vnet -ResourceGroupName $VnetHubRG
Add-AzureRmVirtualNetworkPeering `
  -Name 'hub-to-desarrollo-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId "/subscriptions/d5aae4c2-2452-4174-a138-fcec19d0bc75/resourceGroups/network-desarrollo-rg/providers/Microsoft.Network/virtualNetworks/desarrollo-vnet" -AllowGatewayTransit


Select-AzureRmSubscription -subscriptionid $subdesa
$vNetA=Get-AzureRmVirtualNetwork -Name desarrollo-vnet -ResourceGroupName $VnetdesaRG
Add-AzureRmVirtualNetworkPeering `
  -Name 'desarrollo-to-hub-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId "/subscriptions/03e480f1-3056-4b1d-9ea9-55a152f0d138/resourceGroups/network-hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet" -UseRemoteGateways


## Certificacion to HUB

$subprod = "922a86de-0f41-4bb1-b1cb-4ab1fce2e718"
$subdesa = "d5aae4c2-2452-4174-a138-fcec19d0bc75"
$subhub = "03e480f1-3056-4b1d-9ea9-55a152f0d138"
$subcert = "0c6b7e18-5699-41e7-87bc-2eb6ef2c45c4"
$VnetCertRG = "network-certificacion-rg"


Select-AzureRmSubscription -subscriptionid $subhub
$vNetA=Get-AzureRmVirtualNetwork -Name hub-vnet -ResourceGroupName $VnetHubRG
Add-AzureRmVirtualNetworkPeering `
  -Name 'hub-to-certificacion-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId "/subscriptions/0c6b7e18-5699-41e7-87bc-2eb6ef2c45c4/resourceGroups/network-certificacion-rg/providers/Microsoft.Network/virtualNetworks/certificacion-vnet" -AllowGatewayTransit


Select-AzureRmSubscription -subscriptionid $subcert
$vNetA=Get-AzureRmVirtualNetwork -Name certificacion-vnet -ResourceGroupName $VnetCertRG
Add-AzureRmVirtualNetworkPeering `
  -Name 'certificacion-to-hub-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId "/subscriptions/03e480f1-3056-4b1d-9ea9-55a152f0d138/resourceGroups/network-hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet" -UseRemoteGateways


### Configuracion de circuito Express Route
New-AzureRmExpressRouteCircuit -Name "expressroute-contoso" -ResourceGroupName "network-produccion-rg-01" -Location "eastus2" -SkuTier Premium -SkuFamily MeteredData -ServiceProviderName "Level 3 Communications - IPVPN" -PeeringLocation "Dallas" -BandwidthInMbps 50


## Configuracion de Resource Lock a nivel de Resource Group y todos los recursos que estan dentro en un resource Group especifico

$rgslock = Get-AzureRmResourceGroup -resourcegroupname <Resourcegroupname>

foreach ($rg in $rgslock) {
$rg = $rg.ResourceGroupName
New-AzureRmResourceLock -LockName LockGroup -LockLevel CanNotDelete -ResourceGroupName $rg
}



## Remover LockID de un resource group en este caso "Network-certificacion-rg"
$lockId = (Get-AzureRmResourceLock -ResourceGroupName NETWORK-CERTIFICACION-RG).LockId
Remove-AzureRmResourceLock -LockId $lockId
