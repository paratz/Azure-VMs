$Rules = @(
    @{RuleName="Azure_DataCenter_UScentral";Location="uscentral"},
    @{RuleName="Azure_DataCenter_USnorth";Location="usnorth"},
    @{RuleName="Azure_DataCenter_USwestcentral";Location="uswestcentral"},
    @{RuleName="Azure_DataCenter_USwest2";Location="uswest2"},
    @{RuleName="Azure_DataCenter_USwest";Location="uswest"},
    @{RuleName="Azure_DataCenter_USsouth";Location="ussouth"},
    @{RuleName="Azure_DataCenter_EastUS";Location="useast"},
    @{RuleName="Azure_DataCenter_EastUS2";Location="useast2"}) | % { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }

$SubscriptionID = "cfcb919c-c5a1-4bee-8f4a-5ccaeccc0787"

#This script will search all the NSG in a subscription and will update the required datacenter rule with the IP addresses from the xml file

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
       -ServicePrincipal `
       -TenantId $servicePrincipalConnection.TenantId `
       -ApplicationId $servicePrincipalConnection.ApplicationId `
       -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
   if (!$servicePrincipalConnection)
   {
      $ErrorMessage = "Connection $connectionName not found."
      throw $ErrorMessage
  } else{
      Write-Error -Message $_.Exception
      throw $_.Exception
  }
}

Select-AzureRmSubscription -SubscriptionId $SubscriptionID


#Recorro todos los network security groups y si hay alguna regla de salida que coincide con el nombre definido al principio del script, actualiza la regla.

$nsgs = Get-AzureRmNetworkSecurityGroup

foreach ($nsg in $nsgs) {

    foreach ($secrule in $nsg.SecurityRules) {
        
        foreach ($DCrule in $Rules) {
            
            $OutboundRuleName = $DCRule.RuleName
            $region = $DCrule.Location
                              
            if ($secrule.Name -eq $OutboundRuleName) {

            # Invocar función que trae el contenido del xml con las IPs de Datacenter (https://buildwindows.wordpress.com/2017/11/19/get-azure-datacenter-ip-ranges-via-api/)

            $body = @{“region”=“$region”;“request”=“dcip”} | ConvertTo-Json

            $webrequest = Invoke-WebRequest -Method “POST” -uri `
            https://azuredcip.azurewebsites.net/api/azuredcipranges -Body $body -UseBasicParsing

            ConvertFrom-Json -InputObject $webrequest.Content 

            $IPs = $webrequest.Content

            #Remuevo los ultimos dos caracteres
            $IPs = $IPs.Substring(0,$IPs.Length-2)

            #Remuevo los primero caracteres ( el largo de la locación + 5 otros caracteres que están al principio)
            $IPs = $IPs.Substring($region.Length + 5)

            #Remuevo las comillas
            $IPs = $IPs -replace '["]'

            #Convertir string a array
            $ArrayIPs = $IPs.Split(",")

            #Convertir string a lista generica (el comando Set-AzureRmNetworkSecurityRuleConfig requiere este tipo de objeto para el parametro DestinationAddressPreffix)
            [Collections.Generic.List[String]]$ListaIPs = $ArrayIPs


            $nsgamodificar = Get-AzureRmNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName
        
            Set-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsgamodificar `
            -Name $OutboundRuleName `
            -Description "Allow Access to Azure $($region) Datacenter" `
            -Access Allow `
            -Protocol Tcp `
            -Direction Outbound `
            -Priority $secrule.Priority `
            -SourceAddressPrefix VirtualNetwork `
            -SourcePortRange * `
            -DestinationAddressPrefix $ListaIPs `
            -DestinationPortRange 443

            Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsgamodificar

            }
        }

    }
}