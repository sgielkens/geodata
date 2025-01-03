$items = (Get-ChildItem . -recurse -directory -Filter Trajectory | Resolve-Path -Relative)

foreach ($item in $items) {
	$item_ok = $item + '_ok'
	
	Move-Item $item $item_ok
	mkdir $item_ok\IE
	}
