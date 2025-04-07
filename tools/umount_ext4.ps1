#Requires -RunAsAdministrator

$disk = (GET-CimInstance -ClassName Win32_DiskDrive -Filter "Caption like '%SCSI%'" | select DeviceID -ExpandProperty DeviceID)

if (-not $disk){
	echo "Could not determine disk device"
	exit
}

wsl --unmount $disk
if (-not $?) {
	echo "Could not unmount disk $disk"
}
