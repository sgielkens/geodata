$dir_spherical = 'spherical_images'

mkdir $dir_spherical

$items = (Get-ChildItem . -recurse -directory -Filter Sphere | Resolve-Path -Relative)

foreach ($item in $items) {
	$track = $item -replace "Sphere",""
	
	mkdir $dir_spherical\$track
	
	move-item -path $item -destination $dir_spherical\$track
	}
