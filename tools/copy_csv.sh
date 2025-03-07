#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-i input_dir] [-o output_dir] [-v]

This script copies the csv files to a destination folder.

The options are as follows:
   -i   input directory. By default current directory.
   -o   output directory. By default current directory.
   -v   be verbose
EOF
	exit 1
}

input_dir=$(pwd)
output_dir=$(pwd)

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

if [[ ! -d "$output_dir" ]] ; then
	mkdir -p "$output_dir"
fi

pushd "$input_dir" 1>/dev/null

csv_total=0

find . -type f -name '*.csv' | \
(
	while read i ; do 
		if [[ -n "$verbose" ]] ; then
			echo "$0: copying orientation file:   $i"
		fi

		orientation_dir="${i%/*.*}"
		orientation_file="${i##*/}"
		
		mkdir -p "$output_dir/$orientation_dir"
		cp "$i" "$output_dir/$orientation_dir/"
		
		csv_total=$((csv_total + 1))
	done

echo "$0: copied $csv_total external orientation files" >&2
)

popd 1>/dev/null

exit 0
