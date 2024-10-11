#!/usr/bin/bash

src="/mnt/u/Export_Doesburg/JPEG/Job_20240806_0827/Track36/"
tgt="/mnt/t/export_doesburg/JPEG_fixed/Job_20240815_0857/"

pushd "$src" 1>/dev/null

j=0

find . -type f | \
	while read i ; do 
		if [[ ! -s "$i" ]] ; then
			echo "$i"
			continue
		fi

		jpeg_dir="${i%/*.*}"
		jpeg_file="${i##*/}"
		
		mkdir -p "$tgt/$jpeg_dir"
		cp "$i" "$tgt/$jpeg_dir/"
	
		if [[ "${jpeg_file##*.}" == 'jpg' ]] ; then
			printf '\xD9' >> "$tgt/$i"
		fi
			
	done

popd 1>/dev/null

exit 0