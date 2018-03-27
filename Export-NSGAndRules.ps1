Login-AzureRmAccount

Select-AzureRmSubscription -Subscription 36c19581-28b3-41ad-ad0f-ba6c866e03b6

$myarray = @()

$NSGs = Get-AzureRmNetworkSecurityGroup

foreach ($NSG in $NSGs){

    foreach ($SecRule in $NSG.SecurityRules) {

      $myobj = New-Object -TypeName PSObject

      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'NSGName' -Value $NSG.Name
      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'SecRuleName' -Value $SecRule.Name
      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Protocol' -Value $SecRule.Protocol
      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'SourcePortRange' -Value $SecRule.SourcePortRange
      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'DestinationPortRange' -Value $SecRule.DestinationPortRange
      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'SourceAddressPrefix' -Value $SecRule.SourceAddressPrefix
      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'DestinationAdressPrefix' -Value $SecRule.DestinationAddressPrefix
      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Access' -Value $SecRule.Access
      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Priority' -Value $SecRule.Priority
      Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Direction' -Value $SecRule.Direction 
  
      $myarray += $myobj

    }
 }

 $myarray 



