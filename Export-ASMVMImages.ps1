#Iniciar Sesión en Portal Clásico
Add-AzureAccount

#Listar todas las subscripciones existentes
Get-AzureSubscription

#Seleccionar la subscripción donde se trabajará (reemplazar el subscriptionID obtenido del comando anterior)
Select-AzureSubscription -SubscriptionId cfcb919c-c5a1-4bee-8f4a-5ccaeccc0787

Get-AzureVMImage | where {$_.Category -eq 'User'} | Select-Object * | Export-Csv -Path "C:\Temp2\UserVMImages.csv" -NoTypeInformation

$Imagenes = Get-AzureVMImage | where {$_.Category -eq 'User'} 

foreach ($i in $Imagenes) {

    $ArchivoOS = "C:\Temp2\" + $i.ImageName + "_OS.csv"
    $ArchivoData = "C:\Temp2\" + $i.ImageName + "_Data.csv"

    Get-AzureVMImage $i.ImageName | Get-AzureVMImageDiskConfigSet | select * -ExpandProperty OSDiskConfiguration | Export-Csv -NoTypeInformation -FilePath $ArchivoOS

    Get-AzureVMImage $i.ImageName | Get-AzureVMImageDiskConfigSet | select * -ExpandProperty DataDiskConfigurations | Export-Csv -NoTypeInformation -FilePath $ArchivoData

}
