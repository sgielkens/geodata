$disk = (GET-CimInstance -ClassName Win32_DiskDrive -Filter "Caption like '%SCSI%'" | select DeviceID -ExpandProperty DeviceID)

if (-not $disk){
	wsl --unmount $disk
}
else {
	echo "Could not determine disk device"
}
