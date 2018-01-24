# Based on https://blogs.technet.microsoft.com/keithmayer/2016/01/12/step-by-step-automate-building-outbound-network-security-groups-rules-via-azure-resource-manager-arm-and-powershell/

# Sign-in with Azure account credentials

Login-AzureRmAccount

# Select Azure Subscription

$subscriptionId = 
    (Get-AzureRmSubscription |
     Out-GridView `
        -Title "Select an Azure Subscription ..." `
        -PassThru).SubscriptionId

Select-AzureRmSubscription `
    -SubscriptionId $subscriptionId

# Select Azure Resource Group 

$rgName =
    (Get-AzureRmResourceGroup |
     Out-GridView `
        -Title "Select an Azure Resource Group ..." `
        -PassThru).ResourceGroupName


# Download current list of Azure Public IP ranges
# See this link for latest list

$downloadUri = "https://www.microsoft.com/en-in/download/confirmation.aspx?id=41653"

$downloadPage = 
    Invoke-WebRequest -Uri $downloadUri

$xmlFileUri = 
    ($downloadPage.RawContent.Split('"') -like "https://*PublicIps*")[0]

$response = 
    Invoke-WebRequest -Uri $xmlFileUri


# Get list of regions & public IP ranges

[xml]$xmlResponse = 
    [System.Text.Encoding]::UTF8.GetString($response.Content)

$regions = 
    $xmlResponse.AzurePublicIpAddresses.Region


 # Select Azure regions for which to define NSG rules

$selectedRegions =
    $regions.Name |
    Out-GridView `
        -Title "Select Azure Datacenter Regions ..." `
        -PassThru

$ipRange = 
    ( $regions | 
      where-object Name -In $selectedRegions ).IpRange


#Obtener NSG existente

$nsgid = 
    (Get-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName | Select-Object Name,ResourceGroupName |
     Out-GridView `
        -Title "Select a Network Security Group ..." `
        -PassThru).Name

$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName -Name $nsgid


# Build NSG rules

$rules = @()

$rulePriority = 100

ForEach ($subnet in $ipRange.Subnet) {

    $ruleName = "Allow_Azure_Out_" + $subnet.Replace("/","-")
    
    $rules += 
        Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg `
            -Name $ruleName `
            -Description "Allow outbound to Azure $subnet" `
            -Access Allow `
            -Protocol * `
            -Direction Outbound `
            -Priority $rulePriority `
            -SourceAddressPrefix VirtualNetwork `
            -SourcePortRange * `
            -DestinationAddressPrefix "$subnet" `
            -DestinationPortRange *

    $rulePriority++

}

Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg