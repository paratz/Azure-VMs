Login-AzureRmAccount

Get-AzureRmSubscription

Select-AzureRmSubscription -Subscription df7658fc-00ac-49e2-802f-5cd42ceca7a9

# Buscar IP Publicas sin asociación

Get-AzureRmPublicIpAddress | Where-Object {$_.IpConfiguration -eq $Null}| Select-Object Name,ResourceGroupName,Location,PublicIpAllocationMethod 

# Buscar NICs sin asociación

Get-AzureRmNetworkInterface | Where-Object {$_.VirtualMachine -eq $Null} | Select-Object Name,ResourceGroupName

# Buscar VMs apagadas

$RGs = Get-AzureRMResourceGroup
foreach($RG in $RGs)
{
    $VMs = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName
    foreach($VM in $VMs)
    {
        $VMDetail = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName -Name $VM.Name -Status
        foreach ($VMStatus in $VMDetail.Statuses)
        { 
            if($VMStatus.Code.CompareTo("PowerState/deallocated") -eq 0)
            {
                $VMStatusDetail = $VMStatus.DisplayStatus
                $Output = $VM.Name + " - " + $VMStatusDetail
                write-output $Output
            }
        }
        #write-output $VM.Name $VMStatusDetail
    }
}

# Buscar NSG no asignados

Get-AzureRmNetworkSecurityGroup | Where-Object {($_.NetworkInterfaces -eq $null) -and ($_.Subnets -eq $null)} | Select-Object Name,ResourceGroup

# Recursos Inactivos

Get-AzureRMREsourceGroup | Get-AzureRmResourceGroupDeployment | Where-Object Timestamp -gt (Get-Date).AddDays(-30)

# Encontrar VHD huerfanos

Get-AzureAssessmentOrphanedVhd

# exportar NSGs y sus reglas

$NSG = Get-AzureRmNetworkSecurityGroup

foreach ($NSG in $NSGs){

    foreach ($SecRule in $NSG.SecurityRules) {

    Write-Output "$($NSG.Name),$($SecRule.Name),$($SecRule.Protocol),$($SecRule.SourcePortRange),$($SecRule.DestinationPortRange),$($SecRule.SourceAddressPrefix),$($SecRule.DestinationAddressPrefix),$($SecRule.Access),$($SecRule.Priority),$($SecRule.Direction)"
    
    }

}

# exportar NSGs y sus attachments

$NSG = Get-AzureRmNetworkSecurityGroup

foreach ($NSG in $NSGs){

    foreach ($NIC in $NSG.NetworkInterfaces) {

    Write-Output "$($NSG.Name),$($NIC.Id)"
        
    }

    foreach ($Subnet in $NSG.Subnets) {

    Write-Output "$($NSG.Name),$($Subnet.Id)"
        
    }

}

# exportar NICs y sus IPs

$NICs = Get-AzureRmNetworkInterface | Where-Object {$_.VirtualMachine -ne $Null} 

foreach ($NIC in $NICs) {

    foreach ($IPConfig in $NIC.IpConfigurations) {

        Write-Output "$($NIC.Id),$($IPConfig.PrivateIPAddress),$($IPConfig.PublicIPAddress.Id)" >> nics.txt
    
    }
}

# Listar IPConfig por subnet

$Subnets = Get-AzureRmVirtualNetwork | Get-AzureRmVirtualNetworkSubnetConfig

foreach ($subnet in $Subnets) {
    foreach ($ipconfig in $Subnet.IpConfigurations) {
    Write-Output "$($Subnet.Name),$($Subnet.AddressPrefix),$($IPConfig.Id)" >> ifconfig.txt
    }

}

