## creacion de VNET (Hub\Produccion\Desarrollo\Certificacion)

#Variables Subscription
$subprod = "cbca3a93-a647-464b-b7de-8a3ab84c2a75"
$subdesa = "cbca3a93-a647-464b-b7de-8a3ab84c2a75"
$subhub = "cbca3a93-a647-464b-b7de-8a3ab84c2a75"
$subcert = "cbca3a93-a647-464b-b7de-8a3ab84c2a75"

$VnetProd = "10.10.13.0/24"
$VnetProdRG = "network-prod-rg"
$VnetProdName = "paratz-prod-vnet"
$VnetHub = "10.10.12.0/24"
$VnetHubRG = "network-hub-rg"
$VnetHubName = "paratz-hub-vnet"
$VnetDesa = "10.10.14.0/24"
$VnetDesaRG = "network-dev-rg"
$VnetDesaName = "paratz-dev-vnet"
$VnetCert = "10.10.15.0/24"
$VnetCertRG = "network-qa-rg"
$VnetCertName = "paratz-qa-vnet"
$location = "eastus2"

#Crear Red HUB
#Select-AzureRmSubscription -subscriptionid $subhub
New-AzureRmResourceGroup -name $VnethubRG -Location $location
New-AzureRmVirtualNetwork -ResourceGroupName $VnethubRG -Name $VnetHubName -AddressPrefix $Vnethub -Location $location

#Crear red de producción
#Select-AzureRmSubscription -subscriptionid $subprod
New-AzureRmResourceGroup -Name $VnetProdRG -Location $location
New-AzureRmVirtualNetwork -ResourceGroupName $VnetProdRG -Name $VnetProdName -AddressPrefix $VnetProd -Location $location

#Crear Red de Desa

#Select-AzureRmSubscription -subscriptionid $subdesa
New-AzureRmResourceGroup -name $VnetdesaRG -Location $location
New-AzureRmVirtualNetwork -ResourceGroupName $VnetDesaRG -Name $VnetDesaName -AddressPrefix $VnetDesa -Location $location


#crear Red Certificacion
#Select-AzureRmSubscription -subscriptionid $subcert
New-AzureRmResourceGroup -name $VnetcertRG -Location $location
New-AzureRmVirtualNetwork -ResourceGroupName $VnetcertRG -Name $VnetCertName -AddressPrefix $Vnetcert -Location $location

###subnets

$vNetA=Get-AzureRmVirtualNetwork -Name $VnetHubName -ResourceGroupName $VnetHubRG
$vNetB=Get-AzureRmVirtualNetwork -Name $VnetProdName -ResourceGroupName $VnetProdRG
$vNetC=Get-AzureRmVirtualNetwork -Name $VnetDesaName -ResourceGroupName $VnetDesaRG
$vNetD=Get-AzureRmVirtualNetwork -Name $VnetCertName -ResourceGroupName $VnetCertRG

#Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-hub-vnet-CentralIT-sn" -AddressPrefix "10.10.12.32/27" -VirtualNetwork $vNetA
Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-hub-vnet-DMZIn-sn" -AddressPrefix "10.10.12.64/27" -VirtualNetwork $vNetA
Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-hub-vnet-DMZOut-sn" -AddressPrefix "10.10.12.96/27" -VirtualNetwork $vNetA
Set-AzureRmVirtualNetwork -VirtualNetwork $VnetA

Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-prod-vnet-web-sn" -AddressPrefix "10.10.13.0/27" -VirtualNetwork $vNetB
Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-prod-vnet-buss-sn" -AddressPrefix "10.10.13.32/27" -VirtualNetwork $vNetB
Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-prod-vnet-db-sn" -AddressPrefix "10.10.13.64/27" -VirtualNetwork $vNetB
Set-AzureRmVirtualNetwork -VirtualNetwork $VnetB

Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-dev-vnet-web-sn" -AddressPrefix "10.10.14.0/27" -VirtualNetwork $vNetC
Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-dev-vnet-buss-sn" -AddressPrefix "10.10.14.32/27" -VirtualNetwork $vNetC
Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-dev-vnet-db-sn" -AddressPrefix "10.10.14.64/27" -VirtualNetwork $vNetC
Set-AzureRmVirtualNetwork -VirtualNetwork $VnetC

Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-qa-vnet-web-sn" -AddressPrefix "10.10.15.0/27" -VirtualNetwork $vNetD
Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-qa-vnet-buss-sn" -AddressPrefix "10.10.15.32/27" -VirtualNetwork $vNetD
Add-AzureRmVirtualNetworkSubnetConfig -Name "paratz-qa-vnet-db-sn" -AddressPrefix "10.10.15.64/27" -VirtualNetwork $vNetD
Set-AzureRmVirtualNetwork -VirtualNetwork $VnetD


######### Peering # 


### En el VNET Peering correspondiente a la red del HUB se usa la opcion -allowgatewaytransit y en la red de destino se usa el -UseRemoteGateways
### Hub to Prod

Select-AzureRmSubscription -subscriptionid $subhub
Add-AzureRmVirtualNetworkPeering `
  -Name 'hub-to-prod-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId $VnetB.Id -AllowGatewayTransit
  
Add-AzureRmVirtualNetworkPeering `
  -Name 'prod-to-hub-peering' `
  -VirtualNetwork $vNetB `
  -RemoteVirtualNetworkId $Vneta.Id -UseRemoteGateways

##### Configuracion HUB - DESA

Add-AzureRmVirtualNetworkPeering `
  -Name 'hub-to-dev-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId $Vnetc.Id -AllowGatewayTransit

Add-AzureRmVirtualNetworkPeering `
  -Name 'dev-to-hub-peering' `
  -VirtualNetwork $vNetC `
  -RemoteVirtualNetworkId $VnetA.Id -UseRemoteGateways
  
## Certificacion to HUB

Add-AzureRmVirtualNetworkPeering `
  -Name 'hub-to-qa-peering' `
  -VirtualNetwork $vNetA `
  -RemoteVirtualNetworkId $vNetD.Id -AllowGatewayTransit


Add-AzureRmVirtualNetworkPeering `
  -Name 'qa-to-hub-peering' `
  -VirtualNetwork $vNetD `
  -RemoteVirtualNetworkId $VNetA.Id -UseRemoteGateways


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
