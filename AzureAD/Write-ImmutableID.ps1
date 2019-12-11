param ($UserPrincipalName)
if ($UserPrincipalName -eq $null) {
$UserPrincipalName = read-host -Prompt "Por favor, Ingrese el UserPrincipalName" 
}

#Si hay algun error, que detenga la ejecución
$ErrorActionPreference = 'Stop'

#write-host "If this script were really going to do something, it would do it on $servername in the $envname environment" 

#Limpiamos la variable $ImmutableID de usos anteriores
$ImmutableID = $Null

#Verifica que el usuario cloud no tenga ImmutableID

$ImmutableID = Get-MsolUser -UserPrincipalName $UserPrincipalName| Select-Object ImmutableID

# Obtener Immutable ID en base a cuenta AD Onprem

$ImmutableID = Get-ADUser -Filter "userprincipalname -eq '$UserPrincipalName'" -Properties ObjectGUID | select ObjectGUID | foreach {[system.convert]::ToBase64String(([GUID]($_.ObjectGUID)).tobytearray())}

write-host -ForegroundColor Green "El ImmutableID del Usuario $UserPrincipalName es $ImmutableID"

# Estampar en usuario Cloud el ImmutableID
Write-Host -ForegroundColor Green "Se escribirá el Immutable ID $ImmutableID en el usuario cloud $UserPrincipalName"

Set-MsolUser -UserPrincipalName $UserPrincipalName -ImmutableId $ImmutableID -Verbose

Write-Host -ForegroundColor Green "Se escribió el Immutable ID $ImmutableID en el usuario cloud $UserPrincipalName"
