#Iniciar Sesión en Portal Clásico y ARM
Login-AzureRmAccount

#Listar todas las subscripciones existentes
Get-AzureRMSubscription

#Seleccionar la subscripción donde se trabajará (reemplazar el subscriptionID obtenido del comando anterior)
Select-AzureRmSubscription -SubscriptionId xxxxx-c5a1-4bee-8f4a-5ccaeccc0787

#https://docs.microsoft.com/en-us/powershell/module/azurerm.compute/New-AzureRmImage?view=azurermps-3.7.0
#El siguiente script, importa todas las VM Images exportadas por el script Migrate-ASM2ARM.ps1 en ARM.
#Como parte de la migración de una Storage Account de ASM a ARM, las VM Images no se crean automaticamente en el portal ARM
#Este script toma la configuración exportada de ASM y la importa para crear las imagenes correspondientes en ARM

#Prerequisito: Haber ejecutado Export-ASMVMImages.ps1 en ASM e iniciar sesión en ARM previo a ejecutar este script.

#Definir Working Directory (donde se exportaron los archivos de ASM)
$WorkingDirectory = "C:\Temp2\"

#Definir ubicación de las imagenes
$Location = "West US"

#Definir Resource Group donde las Imagenes se alojaran las imagenes:
$ResourceGroup = "VMImages"

#Importar todas las Imagenes Existentes del Archivo UserVMImages.csv
$ImgCSV = $WorkingDirectory + "UserVMImages.csv"
$Imagenes = Import-Csv -path $ImgCSV

#Recorrer cada imagen
foreach ($I in $Imagenes) {
        #Se crea una nueva configuración de Imagen en ARM
        $imageConfig = New-AzureRmImageConfig -Location $Location;

        #Creo una variable que contiene el nombre del archivo con la configuración del disco de OS
        $OSFile = $WorkingDirectory + $I.ImageName + "_OS.csv"
        #Importo dicho archivo
        $OSDisks = Import-Csv -Path $OSFile
        #Recorro el archivo (en todos los casos hay un solo disco de OS)
        foreach ($OSDisk in $OSDisks) {
            #Configuro la ubicación del disco de OS (MediaLink) en mi $ImageConfig
            Set-AzureRmImageOsDisk -Image $imageConfig -OsType $OSDisk.OS -OsState $OSDisk.OSState -BlobUri $OSDisk.MediaLink

        }

        #Creo la variable que contiene el nombre del archivo con la configuración de discos de datos
        $DataFile = $WorkingDirectory + $I.ImageName + "_OS.csv"
        #Importo dicho archivo
        $DataDisks = Import-Csv -Path $DataFile
        
        #Solo si el archivo tiene contenido, agrego disco de datos, sino no.
        if ($DataDisks -ne $Null) { 
        
            #Defino el numero de la primer LUN
            $Lun = 1
            #Recorro los discos de datos existentes
            foreach ($DataDisk in $DataDisks) {
                #Agrego a la configuración de la imagen cada disco de datos, tiendo en cuenta el número de LUN y su ubicación en la cuenta de storage
                Add-AzureRmImageDataDisk -Image $imageConfig -Lun $Lun -BlobUri $DataDisk.MediaLink
                #Incremento la varieable $Lun asi en la próxima vuelta es la LUN 2 y asi sucesivamente.
                $Lun++

            }
        }        
        
        #Una vez creada la configuración, creo la imagen
        New-AzureRmImage -Image $imageConfig -ImageName $I.ImageName -ResourceGroupName $ResourceGroup -Verbose

}
