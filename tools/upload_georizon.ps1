Function Invoke-Upload {
	param (
		[string]$Project
	)
	
	$pad = "K:\248006 Amsterdam\Verwerking\"
	$pad += $Project
	$pad += ".PegasusProject\Export\JPEG" 
	
	cd $pad
	if ($?)
	{
		echo "Uploading from: $pad"
		C:\Apps\rclone-v1.69.0-windows-amd64\rclone copy -P . Adam:georizon-dataset-01956b2a-6d22-73ca-987a-564483aae531/ingest/
	}
	else
	{
		echo "Path not found: $pad"
	}
	
}

$pad_init=$PWD

Invoke-Upload "Project_20241021_0920"
Invoke-Upload "Project_20241024_1306"
Invoke-Upload "Project_20241025_0915"
Invoke-Upload "Project_20241029_0853"
Invoke-Upload "Project_20241104_0918"
Invoke-Upload "Project_20241104_1206"
Invoke-Upload "Project_20241105_0934"
Invoke-Upload "Project_20241106_0927"
Invoke-Upload "Project_20241112_0936"
Invoke-Upload "Project_20241112_1425"
Invoke-Upload "Project_20241113_1007"
Invoke-Upload "Project_20241113_1154"
Invoke-Upload "Project_20241113_1356"
Invoke-Upload "Project_20241114_1007"
Invoke-Upload "amsterdam_20241121"
Invoke-Upload "Project_20241121_0951"
Invoke-Upload "Project_20241121_1354"
Invoke-Upload "Amsterdam_20241126_0845"
Invoke-Upload "AMS_20241129_0827"
Invoke-Upload "Project_20241203_0939"
Invoke-Upload "Project_20241203_1333"
Invoke-Upload "Amsterdam_20241204_0806"
Invoke-Upload "Project_20241204_1003"
Invoke-Upload "Amsterdam_20241206_0810"
Invoke-Upload "Amsterdam_20241206_1245"
Invoke-Upload "Project_20241210_1134"
Invoke-Upload "Project_20241210_1246"
Invoke-Upload "Project_20241211_0954"
Invoke-Upload "Project_20241211_1256"
Invoke-Upload "Amsterdam_20241212_0916"
Invoke-Upload "Amsterdam_20241216"
Invoke-Upload "Amsterdam_20241217_0845"
Invoke-Upload "Project_20250130_0915"
Invoke-Upload "Project_20250130_1255"
Invoke-Upload "Project_20250131_0919"

cd $pad_init