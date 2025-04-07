#Requires -RunAsAdministrator

$disk = (GET-CimInstance -ClassName Win32_DiskDrive -Filter "Caption like '%SCSI%'" | select DeviceID -ExpandProperty DeviceID)

if (-not $disk){
	echo "Could not determine disk device"
	exit
}

wsl --mount $disk --partition 1
if (-not $?) {
	echo "Could not mount disk $disk"
	exit
}

explorer \\wsl.localhost\Ubuntu\mnt\wsl
