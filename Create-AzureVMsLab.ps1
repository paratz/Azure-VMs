#region begin Inicio de Sesión 

Login-AzureRmAccount

Get-AzureRmSubscription

Select-AzureRmSubscription -SubscriptionId <IDDelaSubscripción>

#endregion

#region begin Crear Resource Group
#Verificar las Ubicaciones disponibles en la subscripción

Get-AzureRmLocation | sort Location | Select Location

$location = "brazilsouth"

#Crear Resource Group

$myResourceGroup = "Contoso-LAB-RG"

New-AzureRmResourceGroup -Name $myResourceGroup -Location $location

#endregion

#region begin Crear Cuenta de Storage

$myStorageAccountName = "Contoso-LAB-StorageAccount"
Get-AzureRmStorageAccountNameAvailability $myStorageAccountName

$myStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $myResourceGroup -Name $myStorageAccountName -SkuName "Standard_LRS" -Kind "Storage" -Location $location

#Crear el Contenedor
New-AzureStorageContainer -name VHDs -Permission Off -Context $myStorageAccount

#endregion 

# Detener VM DT-DC

#region begin Copiar VHDs de OS y Datos de una Cuenta a la nueva cuenta

#################################################
#Copiar OS Disk
#################################################

# Source VHD
$srcVhd = "https://contosostoragebrasil.blob.core.windows.net/vhds/contoso-DC-DTDCAzureBrasil-2015-05-08.vhd"
 
# Destination VHD name
 
$destVhdName = "contoso-LAB-DCAZUREBRASIL-OS.vhd"
 
# Destination Container Name 
$destContainerName = "vhds"
 
# Source Storage Account and Key
 
$srcStorageAccount = "dtstoragebrasil"
$srcStorageKey = "<storageaccountkey>"
 
# Target Storage Account and Key
 
$destStorageAccount = $myStorageAccountName
$destStorageKey = "<storageaccountkey>"
 
# Create the source storage account context (this creates the context, it does not actually create a new storage account)
 
$srcContext = New-AzureStorageContext –StorageAccountName $srcStorageAccount –StorageAccountKey $srcStorageKey
                                         
 
# Create the destination storage account context 
 
$destContext = New-AzureStorageContext –StorageAccountName $destStorageAccount –StorageAccountKey $destStorageKey

 
# Start the copy  
 
$blob1 = Start-AzureStorageBlobCopy -Context $srcContext –AbsoluteUri $srcVhd –DestContainer $destContainerName –DestBlob $destVhdName –DestContext $destContext -Verbose 
 
 
# check status of copy
 
$blob1 | Get-AzureStorageBlobCopyState

#################################################
#Copiar DATA Disk
#################################################

# Source VHD
$srcdataVhd = "https://contosostoragebrasil.blob.core.windows.net/vhds/DT-DC-Azure-DTDCAzureBrasil-0508-1.vhd"
 
# Destination VHD name
 
$destdataVhdName = "contoso-LAB-DCAZUREBRASIL-DATA.vhd"
 
# Destination Container Name 
$destContainerName = "vhds"
 
# Create the source storage account context (this creates the context, it does not actually create a new storage account)
 
$srcContext = New-AzureStorageContext –StorageAccountName $srcStorageAccount –StorageAccountKey $srcStorageKey
                                         
 
# Create the destination storage account context 
 
$destContext = New-AzureStorageContext –StorageAccountName $destStorageAccount –StorageAccountKey $destStorageKey

 
# Start the copy  
 
$blob2 = Start-AzureStorageBlobCopy -Context $srcContext –AbsoluteUri $srcdataVhd –DestContainer $destContainerName –DestBlob $destdataVhdName –DestContext $destContext -Verbose 

 
# check status of copy
 
$blob2 | Get-AzureStorageBlobCopyState

#endregion

#region begin Crear Nueva Maquina Virtual

########################################################################
 
#Create a Virtual Machine from an existing OS disk
 
########################################################################
 

$vmName= "contoso-LAB-DTDCAZUREBRASIL"
$vmSize="Standard_A1"

$myPublicIpName = "contoso-LAB-DTDCAZUREBRASIL-PublicIP"
$vnetName= "contoso-LAB-VNET1"
$SubnetName = "contoso-LAB-VNET1-SUBNET1"
$nicName = "contoso-LAB-DTDCAZUREBRASIL-NIC1"
 
# Get storage account configuration for the target storage account
 
$StorageAccount = Get-AzureRmStorageAccount –ResourceGroupName $myResourceGroup –AccountName $myStorageAccountName
  
#Create and Get Virtual Network configuration

$myPublicIp = New-AzureRmPublicIpAddress -Name $myPublicIpName -ResourceGroupName $myResourceGroup -Location $location -AllocationMethod Dynamic

$mySubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix 192.168.0.0/24

New-AzureRmVirtualNetwork -ResourceGroupName $myResourceGroup -Name $vnetName -AddressPrefix 192.168.0.0/16 -Location $location -Subnet $mysubnet

$vnet = Get-AzureRmVirtualNetwork -Name $vnetName –ResourceGroupName $myResourceGroup 
 
# Create VM from an existing image

$vm = New-AzureRmVMConfig –vmName $vmName –vmSize $vmSize
  
$nic = New-AzureRmNetworkInterface -Name $nicName –ResourceGroupName $myResourceGroup -Location $location –SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $myPublicIp.Id 

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id 

#Conseguir la URI del disco copiado

$StorageAccountContext = New-AzureStorageContext –StorageAccountName $myStorageAccountName –StorageAccountKey $myStorageAccountKey

$destOSDiskUri = (Get-AzureStorageBlob -blob $destVhdName -Container $destContainerName -Context $StorageAccountContext ).ICloudBlob.uri.AbsoluteUri 
    
# Set the OS disk properties for the new VM. If you are migrating a Linux machine use the -Linux switch instead of -Windows

$vm = Set-AzureRmVMOSDisk -VM $vm -Name $destVhdName –VhdUri $destOSDiskUri -Windows –CreateOption attach

$DataDiskUri = (Get-AzureStorageBlob -blob $destdataVhdName -Container $destContainerName -Context $StorageAccountContext ).ICloudBlob.uri.AbsoluteUri 

$vm = Add-AzureRmVMDataDisk -VM $vm -Name "DT-LAB-DTDCAZUREBRASIL-DATADISK1" -VhdUri $DataDiskUri -Lun 0 -DiskSizeinGB 5 -CreateOption Attach

New-AzureRmVM –ResourceGroupName $myresourcegroup -Location $location -VM $vm

#endregion 
