############################################################################################################
# Paso 3 - Aplicar politicas basicas:                                                                      #
#                                                                                                          #
#     -Locaciones Permitidas para RGs                                                                      #
#     -Locaciones Permitidas para Recursos                                                                 #
#                                                                                                          #
# Politica que restringe la locacion de un resource group                                                  #
############################################################################################################

#region armpolicies

$policyDefinitionName = [guid]::NewGuid().Guid.ToUpper().Replace("-", "")
$policyDefinitionDisplayName = "Policies-General-LocacionesPermitidas-ResourceGroups"
$policyDefinitionDescription = "Esta política restringe las locaciones de creacion de grupos de recursos"

$definition1 = New-AzureRmPolicyDefinition -Name $policyDefinitionName -DisplayName $policyDefinitionDisplayName `
 -Description $policyDefinitionDescription `
 -Policy 'C:\GitHub\Azure-VMs\AzurePolicies\Policy-RGAllowedLocations.rule.json' `
 -Metadata 'C:\GitHub\Azure-VMs\AzurePolicies\Policy-RGAllowedLocations.metadata.json' `
 -Parameter 'C:\GitHub\Azure-VMs\AzurePolicies\Policy-RGAllowedLocations.parameters.json'

# Politica que restringe la locacion de un recursos

$policyDefinitionName = [guid]::NewGuid().Guid.ToUpper().Replace("-", "")
$policyDefinitionDisplayName = "Policies-General-LocacionesPermitidas-Resources"
$policyDefinitionDescription = "Esta política restringe las locaciones de creacion de los recursos"

$definition2 = New-AzureRmPolicyDefinition -Name $policyDefinitionName -DisplayName $policyDefinitionDisplayName `
 -Description $policyDefinitionDescription `
 -Policy 'C:\GitHub\Azure-VMs\AzurePolicies\Policy-ResourcesAllowedLocations.rule.json' `
 -Metadata 'C:\GitHub\Azure-VMs\AzurePolicies\Policy-ResourcesAllowedLocations.metadata.json' `
 -Parameter 'C:\GitHub\Azure-VMs\AzurePolicies\Policy-ResourcesAllowedLocations.parameters.json'

# Asignar politicas a la subscripciones

$definitions = Get-AzureRmPolicyDefinition | Where-Object { $_.Properties.DisplayName -like '*Policies*' }
$Locations = Get-AzureRmLocation | where displayname -like "*east*"
$AllowedLocations = @{"listOfAllowedLocations"=($Locations.location)}
foreach($definition in $definitions)
{
    New-AzureRmPolicyAssignment -Name $definition.Properties.displayName -Scope $subscriptionUri -PolicyDefinition $definition -PolicyParameterObject $AllowedLocations
}

