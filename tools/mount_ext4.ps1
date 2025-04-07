$disk = (GET-CimInstance -ClassName Win32_DiskDrive -Filter "Caption like '%SCSI%'" | select DeviceID -ExpandProperty DeviceID)

if (-not $disk){
	wsl --mount $disk --partition 1
	explorer \\wsl.localhost\Ubuntu\mnt\wsl
}
else {
	echo "Could not determine disk device"
}
