#SubscriptionName                 SubscriptionId                      
#----------------                 --------------                      
#Visual Studio Enterprise         xxxxxx-f464-45d8-adeb-c7a0e8c678f6
#Visual Studio Ultimate with MSDN xxxxxx-c5a1-4bee-8f4a-5ccaeccc0787

Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId xxxxx-c5a1-4bee-8f4a-5ccaeccc0787

#Iniciar Sesión en Portal Clásico
Add-AzureAccount

#Listar todas las subscripciones existentes
Get-AzureSubscription

#Seleccionar la subscripción donde se trabajará (reemplazar el subscriptionID obtenido del comando anterior)
Select-AzureSubscription -SubscriptionId xxxxxx-c5a1-4bee-8f4a-5ccaeccc0787

#Registrar subscripción, y esperar 5 minutos

Register-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate

#Verificar que la subscripción esté registrada

Get-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate

#Verificar que hay suficientes cores en la región

Get-AzureRmVMUsage -Location "East US"

# Validar Movimiento:

$vnetName = "ImageMig"
$MensajeDeError = (Move-AzureVirtualNetwork -Validate -VirtualNetworkName $vnetName -Verbose)
$MensajeDeError.ValidationMessages | clip

$MensajeDeError.ValidationMessages | Export-Csv -Path "C:\temp2\ValidationMsg3.csv"


#Preparar Movimiento

Move-AzureVirtualNetwork -Prepare -VirtualNetworkName $vnetName -Verbose

#Commit del movimiento

Move-AzureVirtualNetwork -Commit -VirtualNetworkName $vnetName -Verbose

# Migración de Cuentas de Storage:
#Listar Cuentas de Storage
Get-AzureStorageAccount | Select-Object StorageAccountName

#StorageAccountName      
#------------------      
#04portalvhdsb88lwjkqv8vx
#j9portalvhdsk0dkmmyfrv2n
#paratztorage1           
#portalvhds3qj925pl3zhwm 
#portalvhdsn90jys9fwsnq9 
#syscenfakstorage        
#wsazureparatzstorag

#Prerequisitos

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

# Si aparece algo de lo anteiror, hay que eliminarlos:

#Remove-AzureVMImage -ImageName 'yourImageName'

#Remove-AzureDisk -DiskName 'yourDiskName'


#Remove-AzureDisk -DiskName 'OCS2007EDGE-OCS2007EDGE-0-201305150208230081'
#Remove-AzureDisk -DiskName 'msclient-msclient-0-201308140208160345'
#Remove-AzureDisk -DiskName 'tmg-tmg-0-201305150222470950'
#Remove-AzureDisk -DiskName 'iisvm1-iisvm1-0-201502182109550265'



#1er paso migración storage

foreach ($st in $CuentasDeAlmacenamiento) {

    Move-AzureStorageAccount -Prepare -StorageAccountName $st.StorageAccountName -Verbose

}

#2do paso

foreach ($st in $CuentasDeAlmacenamiento) {

    Move-AzureStorageAccount -Commit -StorageAccountName $st.StorageAccountName -Verbose

}

#    Move-AzureStorageAccount -Commit -StorageAccountName paratztorage1 
#    Move-AzureStorageAccount -Commit -StorageAccountName portalvhdsn90jys9fwsnq9  
    