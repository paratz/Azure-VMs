$SAPPublicIP = "23.99.221.164"
$SAPEncryptionDomain = "10.5.51.0/24","192.168.1.0/24","13.0.0.0/8"
$PreSharedKey = "Ap4JlhhMUW3o7EjzT8soBfBFthUJEE"

$ProdSubscription = "cbca3a93-a647-464b-b7de-8a3ab84c2a75"
$RGGroupName = "network-hub-rg"
$LocalNetworkGatewayName = "LNG-SAPHEC-Site2Site"
$VNETGWConnectionName = "CONN-SAPHEC-Azure"
$VnetGateway = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $RGGroupName -Name "PARATZ-HUB-VNETGW"
$Location = "eastus2"

#Inicio de Sesión en Azure
Login-AzureRmAccount

#Selección de la subscripción de Producción
Select-AzureRmSubscription -Subscription $ProdSubscription

#Creación del Local Area Network Gateway
New-AzureRmLocalNetworkGateway -Name $LocalNetworkGatewayName -ResourceGroupName $RGGroupName -Location $Location -GatewayIpAddress $SAPPublicIP -AddressPrefix $SAPEncryptionDomain

#Guardamos el ID del objeto recientemente creado
$RemoteGateway = Get-AzureRmLocalNetworkGateway -Name $LocalNetworkGatewayName -ResourceGroupName $RGGroupName

#Creación de la conexión
New-AzureRmVirtualNetworkGatewayConnection -Name $VNETGWConnectionName -ResourceGroupName $RGGroupName -VirtualNetworkGateway1 $VnetGateway -LocalNetworkGateway2 $RemoteGateway -Location $Location -ConnectionType IPSec -SharedKey $PreSharedKey