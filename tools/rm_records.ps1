cd \\wsl.localhost\Ubuntu\mnt\wsl

$drive = (Get-ChildItem . -directory -filter 'PHYSICALDRIVE*')

$number = (echo $drive | Measure-Object).Count

if ($number -ne 1) {
	echo "More than 1 candidate drive detected"
	echo $drive
	echo "Remove external disks other than the disk reader"
	exit
}

cd $drive

$recs = (Get-ChildItem . -Exclude 'lost+found')

foreach ($rec in $recs{
	rec_path = "/mnt/wsl/$drive/$rec"

	wsl --user root rm -fr "$rec_path"

	if (-not $?) {
		echo "Could not remove directory $rec_path"
	}
}

