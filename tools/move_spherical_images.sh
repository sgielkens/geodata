#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-i input_dir] [-o output_dir] [-v]

This script moves the spheric images only to a destination folder.
If no output directory is specified, a subdirectory $dir_spherical will
be created in the input directory.

The options are as follows:
   -i   input directory. By default current directory.
   -o   output directory. By default current directory.
   -v   be verbose
EOF
	exit 1
}

dir_spherical=JPEG_Sphere

input_dir=$(pwd)

unset verbose

while getopts ":i:o:v" option ; do
   case ${option} in
      "i") input_dir="${OPTARG}"
           ;;
      "o") output_dir="${OPTARG}"
           ;;
      "v") verbose="yes"
           ;;
      *) usage
         ;;
   esac
done

if [[ ! -d "$input_dir" ]] ; then
	echo "$0: input directory $input_dir does not exist" >&2
	exit 1
fi

if [[ -z "$output_dir" ]] ; then
	output_dir="$input_dir"
fi
output_dir=${output_dir}/${dir_spherical}

if [[ ! -d "$output_dir" ]] ; then
	mkdir -p "$output_dir"
fi

pushd "$input_dir" 1>/dev/null

ls -d Track*/Sphere | \
	while read i ; do
		if [[ -n "$verbose" ]] ; then
			echo "$0: moving spherical images from $i"
		fi

		track=${i%/Sphere}
		mkdir -p "$output_dir/$track"
		mv "$i" "$output_dir/$track"
	done

popd 1>/dev/null

pushd "$output_dir" 1>/dev/null
find . -type f -size 0 -exec rm {} \;
popd 1>/dev/null

exit 0
