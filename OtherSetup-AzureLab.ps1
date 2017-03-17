#region Definición de Variables

$SubscriptionID = "5ab28d9e-f464-45d8-adeb-c7a0e8c678f6"

$ResourceGroupName = "PLRLab"
$RGLocation = "brazilsouth"
# List of available regions is 'centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus,
# southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest,brazilsouth,australiasoutheast,
# australiaeast,westindia,southindia,centralindia,canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth'

$StorageAccountType = "Standard_LRS"
#"Standard_LRS,Standard_ZRS,Standard_GRS,Standard_RAGRS,Premium_LRS"

$1stVMLocalPathOSDisk = "C:\Users\Arwen\Documents\Virtual Machines\DC1ConvertedDisk\DC1-OS.vhd"
$1stVMOSDiskName = "DC1OS.vhd"

$1stVMLocalPathVMDATADisk = "C:\Users\Arwen\Documents\Virtual Machines\DC1ConvertedDisk\DC1-DATA.vhd"
$1stVMDATADiskName = "DC1DATA.vhd"

$vnetprefix = "10.0.0.0/16"
$subnetprefix = "10.0.0.0/24"
$PrivateIPAddress = "10.0.0.11"

$1stDNSServer = $PrivateIPAddress
$2ndDNSServer = "10.0.0.12"

$VMName = "DC01"
$VMSize = "Standard_A2_v2"

#Para ver la lista de tamaños disponibles en la versión elegida ejecutar:
#Get-AzureRmVmSize -Location $RGLocation | Sort-Object Name | ft Name, NumberOfCores, MemoryInMB, MaxDataDiskCount -AutoSize

#endregion

#region Inicio de Sesión 

#Instalar modulo de Powershell de Azure en caso de que no esté instalado
Install-Module AzureRM.Compute -RequiredVersion 2.6.0

Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId $SubscriptionId

#endregion

#region Creación de grupo de recursos y cuenta de almacenamiento

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $RGLocation 

$StorageAccountName = $ResourceGroupName + "Storage"

New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName.ToLower() -Location $RGLocation -Type $StorageAccountType

#endregion

#region Subir Discos OS y Datos Maquina 1

$StorageAccountContainer = "vhds"
$urlOfUploadedImageOSVhd = "https://" + $StorageAccountName.ToLower() + ".blob.core.windows.net/" + $StorageAccountContainer + "/" + $1stVMOSDiskName

Add-AzureRmVhd -ResourceGroupName $ResourceGroupName -Destination $urlOfUploadedImageOSVhd -LocalFilePath $1stVMLocalPathOSDisk

$urlOfUploadedImageDATAVhd = "https://" + $StorageAccountName.ToLower() + ".blob.core.windows.net/" + $StorageAccountContainer + "/" + $1stVMDATADiskName

Add-AzureRmVhd -ResourceGroupName $ResourceGroupName -Destination $urlOfUploadedImageDATAVhd -LocalFilePath $1stVMLocalPathVMDATADisk

#endregion

#region crear red virtual, subnet, public ip, nic y ngs

$vnetName = $ResourceGroupName + "-VNET"
$subnetName = $vnetName + "-Subnet01"

$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetprefix
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName -Location $RGLocation -AddressPrefix $vnetprefix -Subnet $singleSubnet

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -name $vnetName 
$vnet.DhcpOptions.DnsServers = $1stDNSServer
$vnet.DhcpOptions.DnsServers += $2ndDNSServer 
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet


$PublicIPName = $vmname + "-PublicIP"

$pip = New-AzureRmPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -Location $RGLocation `
     -AllocationMethod Dynamic

$nicName = $VMName + "-NIC1"

$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $ResourceGroupName `
 -Location $RGLocation -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress $PrivateIPAddress

$nsgName = $VMName + "-NetworkSecurityGroup"
$RdpruleName = $VMName + "-RDPRule"

$rdpRule = New-AzureRmNetworkSecurityRuleConfig -Name $RdpruleName -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $RGLocation `
    -Name $nsgName -SecurityRules $rdpRule

#endregion

#region configurar VM

$vmConfig = New-AzureRmVMConfig -VMName $vmname -VMSize $VMSize

$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

$OSDiskName = $VMName + "-OSDisk"
$urlOfUploadedImageOSVhd = "https://" + $StorageAccountName.ToLower() + ".blob.core.windows.net/" + $StorageAccountContainer + "/" + $1stVMOSDiskName

#Crear el Disco utilizando Managed Disk (no funiciona en este momento)
#$osDisk = New-AzureRmDisk -DiskName $OSDiskName -Disk (New-AzureRmDiskConfig `
#-AccountType $StorageAccountType  -Location $RGLocation -CreationDataCreateOption Import `
#-SourceUri $urlOfUploadedImageOSVhd ) `
#-ResourceGroupName $ResourceGroupName
#
# $vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -ManagedDiskStorageAccountType $StorageAccountType `
# -DiskSizeInGB 128 -CreateOption Attach -Windows

$vm = Set-AzureRmVMOSDisk -VM $vm -Name $OSDiskName -VhdUri $urlOfUploadedImageOSVhd -CreateOption attach -Windows

$DataDiskName = $VMName + "-DATADisk"
$urlOfUploadedImageDATAVhd = "https://" + $StorageAccountName.ToLower() + ".blob.core.windows.net/" + $StorageAccountContainer + "/" + $1stVMDATADiskName

#Crear el Disco utilizando Managed Disk (no funiciona en este momento)
#$DataDisk = New-AzureRmDisk -DiskName $DataDiskName -Disk (New-AzureRmDiskConfig ` 
# -AccountType $StorageAccountType -Location $RGLocation -CreateOption Import `
# -SourceUri $urlOfUploadedImageDATAVhd) `
# -ResourceGroupName $ResourceGroupName
#
#$vm = Add-AzureRmVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $DataDisk.Id -Lun 1

$DataDiskSize = 10
$vm = Add-AzureRmVMDataDisk -VM $vm -Name $DataDiskName -VhdUri $urlOfUploadedImageDATAVhd -Lun 1 -CreateOption attach -DiskSizeInGB $DataDiskSize

#endregion

#region Crear VM

New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $RGlocation -VM $vm

#endregion

#region links adicionales
#
# https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-create-vm-specialized?toc=%2fazure%2fvirtual-machines%2fwindows%2ftoc.json
# https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-create-managed-disk-ps
# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-static-private-ip-arm-ps
# https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-sizes
# https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-common-deployment-errors#skunotavailable
# https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-ps-create
# 
#endregion
