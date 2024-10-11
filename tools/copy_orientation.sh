#!/usr/bin/bash

src="/mnt/t/export_sphere/input_1/Beek_26092024/Job_20240926_0724"
tgt="/mnt/d/BLUR_Rivierenland/Blurred/output_1/Beek_26092024/Job_20240926_0724"

pushd "$src" 1>/dev/null

j=0

find . -type f -name '*.txt' -o -name '*.csv' | \
(
	while read i ; do 
		orientation_dir="${i%/*.*}"
		orientation_file="${i##*/}"
		
		mkdir -p "$tgt/$orientation_dir"
		cp "$i" "$tgt/$orientation_dir/"
		
		j=$((j + 1))
	done

echo "$0: copied $j orientation files" >&2
)

popd 1>/dev/null

pushd "$tgt" 1>/dev/null
find . -type f -name *.json -exec rm {} \;
popd 1>/dev/null

exit 0