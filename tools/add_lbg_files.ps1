$items = (Get-ChildItem . -directory -filter '2025*')

foreach ($item in $items) {
	copy ../../setup.hsf $item
	copy ../../alphamask_*.jpg $item
}
