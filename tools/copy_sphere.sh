#!/usr/bin/bash

src="/mnt/v/1045001_Rivierenland/Verwerking/24006 Berg en Dal/Beek_26092024.PegasusProject/Export/JPEG/Job_20240926_0724"
tgt="/mnt/t/export_sphere/Beek_26092024/Job_20240926_0724"

pushd "$src" 1>/dev/null

ls -d Track*/Sphere | \
	while read i ; do
		track=${i%/Sphere}
		mkdir -p "$tgt/$track"
		cp -ax "$i" "$tgt/$track"
	done

popd 1>/dev/null

pushd "$tgt" 1>/dev/null
find . -type f -size 0 -exec rm {} \;
popd 1>/dev/null

exit 0