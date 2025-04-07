$disk = (GET-CimInstance -ClassName Win32_DiskDrive -Filter "Caption like '%SCSI%'" | select DeviceID -ExpandProperty DeviceID)

if ($disk){
	wsl --unmount $disk
}
