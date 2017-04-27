#Definir nombre de vnet a migrar y datacenter
$vnetName = "ImageMig"
$Location = "West US"

#Iniciar Sesión en Portal Clásico y ARM
Add-AzureAccount
Login-AzureRmAccount

#Listar todas las subscripciones existentes
Get-AzureSubscription

#Seleccionar la subscripción donde se trabajará (reemplazar el subscriptionID obtenido del comando anterior)
Select-AzureSubscription -SubscriptionId xxxxxx-c5a1-4bee-8f4a-5ccaeccc0787
Select-AzureRmSubscription -SubscriptionId xxxxx-c5a1-4bee-8f4a-5ccaeccc0787

#Registrar subscripción, y esperar 5 minutos

Register-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate

#Verificar que la subscripción esté registrada

Get-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate

#Verificar que hay suficientes cores en la región

Get-AzureRmVMUsage -Location $Location

# Validar Movimiento:

$MensajeDeError = (Move-AzureVirtualNetwork -Validate -VirtualNetworkName $vnetName -Verbose)

#Con este comando, la validación se copia en el portapapeles
$MensajeDeError.ValidationMessages | clip

#Con este comando, la validación se exporta a un archivo .csv
$MensajeDeError.ValidationMessages | Export-Csv -Path "C:\temp2\ValidationMsg3.csv"


#Preparar Movimiento

Move-AzureVirtualNetwork -Prepare -VirtualNetworkName $vnetName -Verbose

#Commit del movimiento

Move-AzureVirtualNetwork -Commit -VirtualNetworkName $vnetName -Verbose


##################################
# Migración de Cuentas de Storage#
##################################


#Listar Cuentas de Storage
Get-AzureStorageAccount | Select-Object StorageAccountName

#Estos comandos ejecutan los queries para encontrar VHD desconectados o imagenes de VMs:

$CuentasDeAlmacenamiento = Get-AzureStorageAccount

foreach ($st in $CuentasDeAlmacenamiento) {

            #Preceding command returns RoleName and DiskName properties of all the classic VM disks in the storage account. RoleName is the name of the virtual machine to which a disk is attached. If preceding command returns disks then ensure that virtual machines to which these disks are attached are migrated before migrating the storage account.
            
                Get-AzureDisk | where-Object {$_.MediaLink.Host.Contains($st.StorageAccountName)} | Select-Object -ExpandProperty AttachedTo -Property `
                DiskName | Format-List -Property RoleName, DiskName

            #Find unattached classic VM disks in the storage account using following command: 

                  Get-AzureDisk | where-Object {$_.MediaLink.Host.Contains($st.StorageAccountName)} | Format-List -Property DiskName

                  Get-AzureVmImage | Where-Object { $_.OSDiskConfiguration.MediaLink -ne $null -and $_.OSDiskConfiguration.MediaLink.Host.Contains($st.StorageAccountName)`
                                          } | Select-Object -Property ImageName, ImageLabel

            #Preceding command returns all the VM images with OS disk stored in the storage account.

            Get-AzureVmImage | Where-Object { $_.OSDiskConfiguration.MediaLink -ne $null -and $_.OSDiskConfiguration.MediaLink.Host.Contains($st.StorageAccountName)`
                                          } | Select-Object -Property ImageName, ImageLabel


            # Preceding command returns all the VM images with data disks stored in the storage account.

            Get-AzureVmImage | Where-Object {$_.DataDiskConfigurations -ne $null `
                                                   -and ($_.DataDiskConfigurations | Where-Object {$_.MediaLink -ne $null -and $_.MediaLink.Host.Contains($st.StorageAccountName)}).Count -gt 0 `
                                                  } | Select-Object -Property ImageName, ImageLabel

}

# Si aparece algo de lo anteiror, hay que eliminarlos, caso contrario fallará la migración de la cuenta de almacenamiento:
#Remove-AzureDisk -DiskName 'yourDiskName'

#1er paso migración storage para todas las cuentas de almacenamiento:

foreach ($st in $CuentasDeAlmacenamiento) {

    Move-AzureStorageAccount -Prepare -StorageAccountName $st.StorageAccountName -Verbose

}

#2do paso migración storage para todas las cuentas de almacenamiento:

foreach ($st in $CuentasDeAlmacenamiento) {

    Move-AzureStorageAccount -Commit -StorageAccountName $st.StorageAccountName -Verbose

}


#Si en la operación anterior, algo falló, puede volver a ejecutarse utilizando el mismo comando para una cuenta de almacenamiento en particular, por ejemplo:
#    Move-AzureStorageAccount -Commit -StorageAccountName paratztorage1 
