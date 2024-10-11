#!/usr/bin/bash

src="/mnt/d/Test"
tgt="/mnt/t/export_sphere/Beek_26092024/Job_20240926_0724"

pushd "$src" 1>/dev/null

dir_spherical='spherical_images'
mkdir "$dir_spherical"


ls -d Track*/Sphere | \
	while read i ; do
		track=${i%/Sphere}
		mkdir -p "$dir_spherical/$track"
		mv "$i" "$dir_spherical/$track"
	done

popd 1>/dev/null

exit 0