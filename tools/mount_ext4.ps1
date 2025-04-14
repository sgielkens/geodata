#Requires -RunAsAdministrator

# ignore portable SSDs

$disk = (GET-CimInstance -ClassName Win32_DiskDrive -Filter "Caption like '%SCSI%' and not Caption like '%Portable%'" | select DeviceID -ExpandProperty DeviceID)

$number = (echo $disk | Measure-Object).Count

if ($number -ne 1) {
	echo "More than 1 candidate disk detected"
	echo $disk
	echo "Remove external disks other than the disk reader"
	exit
}

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
