#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-i input_dir] [-v]

This script removes empty images, i.e. images with size zero.
The corresponding csv file is cleansed as well from these empty jpeg's.

The options are as follows:
   -i   input directory. By default current directory.
   -v   be verbose
EOF
	exit 1
}

input_dir=$(pwd)

unset verbose

while getopts ":i:v" option ; do
   case ${option} in
      "i") input_dir="${OPTARG}"
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

tmp_file="$(mktemp)"
if [[ $? -ne 0 ]] ; then
	echo "$0: could not create temporary file" >&2
	exit 1
fi

trap 'rm -f "$tmp_file"' EXIT

pushd "$input_dir" 1>/dev/null

unset rm_opts
if [[ -n "$verbose" ]] ; then
	rm_opts='--verbose'
fi

find . -type f -size 0 > "$tmp_file"

if [[ ! -s "$tmp_file" ]] ; then
	echo "$0: no empty images" >&2
	exit 0
fi

while read i ; do
	jpeg_image=${i##*/}

	csv_file="${i%_*.jpg}"'.csv'
	csv_with_empty_jpeg="$csv_file"'.with_empty_jpeg'

	if [[ ! -f "$csv_with_empty_jpeg" ]] ; then
		# Save per track, not per empty image
		cp "$csv_file" "$csv_with_empty_jpeg"
	fi

	rm $rm_opts $i

	if [[ -n "$verbose" ]] ; then
		echo "$0: removing empty image $jpeg_image from csv $csv_file" >&2
	fi

	sed -i -n -e '/'${jpeg_image}'/d;p' "$csv_file"
	if [[ $? -ne 0 ]] ; then
		echo "$0: cleansing of csv $csv_file failed" >&2
	fi
done < "$tmp_file"

popd 1>/dev/null

exit 0
