$NSGName = "fabwap1-nsg"
$OutboundRuleName = "Azure_WestUS"
$RGName = "fabrikam.com.ar"
$SubscriptionID = "cfcb919c-c5a1-4bee-8f4a-5ccaeccc0787"
$region = "uswest"

Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId $SubscriptionID


# Invocar función que trae el contenido del xml con las IPs de Datacenter (https://buildwindows.wordpress.com/2017/11/19/get-azure-datacenter-ip-ranges-via-api/)

$body = @{“region”=“uswest”;“request”=“dcip”} | ConvertTo-Json

$webrequest = Invoke-WebRequest -Method “POST” -uri `
https://azuredcip.azurewebsites.net/api/azuredcipranges -Body $body

ConvertFrom-Json -InputObject $webrequest.Content 

$IPs = $webrequest.Content

#Remuevo los ultimos dos caracteres
$IPs = $IPs.Substring(0,$IPs.Length-2)

#Remuevo los primero caracteres ( el largo de la locación + 5 otros caracteres que están al principio)
$IPs = $IPs.Substring($region.Length + 5)

#Remuevo las comas
$IPs = $IPs -replace '["]'

#Convertir string a array
$ArrayIPs = $IPs.Split(",")

#Convertir string a lista generica (el comando AzureRmNetworkSecurityRuleConfig requiere este tipo de objeto para el parametro DestinationAddressPreffix)
[Collections.Generic.List[String]]$ListaIPs = $ArrayIPs

# Modificar Regla

$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $RGName -Name $NSGName

    Set-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg `
    -Name $OutboundRuleName `
    -Description "Allow Access to Azure $($region) Datacenter" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Outbound `
    -Priority 666 `
    -SourceAddressPrefix VirtualNetwork `
    -SourcePortRange * `
    -DestinationAddressPrefix $ListaIPs `
    -DestinationPortRange 443

    Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg
