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



$redesdestino = $null


ForEach ($subnet in $ipRange.Subnet) {

$redesdestino += $subnet + ","

}

$redesdestino = $redesdestino.Substring(0,$redesdestino.Length-1)

$redesdestino | clip

