param ($UserPrincipalName)
if ($UserPrincipalName -eq $null) {
$UserPrincipalName = read-host -Prompt "Por favor, Ingrese el UserPrincipalName" 
}

Start-Transcript

#Si hay algun error, que detenga la ejecución
$ErrorActionPreference = 'Stop'

#write-host "If this script were really going to do something, it would do it on $servername in the $envname environment" 

#Limpiamos la variable $ImmutableID de usos anteriores
$ImmutableID = $Null

# Obtener Immutable ID en base a cuenta AD Onprem

$ImmutableID = Get-ADUser -Identity $UserPrincipalName -Properties ObjectGUID | select ObjectGUID | foreach {[system.convert]::ToBase64String(([GUID]($_.ObjectGUID)).tobytearray())}
write-host "El ImmutableID del Usuario $UserPrincipalName es $ImmutableID"

# Estampar en usuario Cloud el ImmutableID
Write-Host "Se escribirá el Immutable ID $ImmutableID en el usuario cloud $UserPrincipalName"

Set-MsolUser -UserPrincipalName $UserPrincipalName -ImmutableId $ImmutableID -Verbose

Write-Host "Se escribió el Immutable ID $ImmutableID en el usuario cloud $UserPrincipalName"

Stop-Transcript