$WorkingDirectory = "C:\Temp2\"

#Iniciar Sesión en Portal Clásico
Add-AzureAccount

#Listar todas las subscripciones existentes
Get-AzureSubscription

#Seleccionar la subscripción donde se trabajará (reemplazar el subscriptionID obtenido del comando anterior)
Select-AzureSubscription -SubscriptionId xxxxxxxx-xxxxxxxxxxxxxxxx-xxxxxxxx-xxxxxxxx

$ImgCSV = $WorkingDirectory + "UserVMImages.csv"

Get-AzureVMImage | where {$_.Category -eq 'User'} | Select-Object * | Export-Csv -Path $ImgCSV -NoTypeInformation

$Imagenes = Get-AzureVMImage | where {$_.Category -eq 'User'} 

foreach ($i in $Imagenes) {

    $ArchivoOS = $WorkingDirectory + $i.ImageName + "_OS.csv"
    $ArchivoData = $WorkingDirectory + $i.ImageName + "_Data.csv"

    Get-AzureVMImage $i.ImageName | Get-AzureVMImageDiskConfigSet | select * -ExpandProperty OSDiskConfiguration | Export-Csv -NoTypeInformation -FilePath $ArchivoOS

    Get-AzureVMImage $i.ImageName | Get-AzureVMImageDiskConfigSet | select * -ExpandProperty DataDiskConfigurations | Export-Csv -NoTypeInformation -FilePath $ArchivoData

}
