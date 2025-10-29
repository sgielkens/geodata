#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-d] [-i input_dir] [-v]

This script removes from csv files coordinates with value 0.
If these zero coordinates are present, a backup of the original csv is made.

It searches recursively for csv files in the track directory.
It is assumed that the x and y coordinates are in columns 3 and 4 respectively.

The options are as follows:
   -d   be very verbosea for debugging
   -i   input track directory. By default current directory.
   -v   be verbose
EOF
	exit 1
}

track_dir="$(pwd)"

unset verbose
unset debug

while getopts ":di:v" option ; do
   case ${option} in
      "d") debug="yes"
           ;;
      "i") track_dir="${OPTARG}"
           ;;
      "v") verbose="yes"
           ;;
      *) usage
         ;;
   esac
done


if [[ ! -d "$track_dir" ]] ; then
	echo "$0: track directory $track_dir does not exist" >&2
	exit 1
fi

pushd "$track_dir" 1>/dev/null

i=0
rc=0

find . -name '*.csv' | \
(	
	while read csv_file ; do
		if [[ -n "$debug" ]] ; then
			echo "$0: checking for zero coordinates for $csv_file"
		fi

		csv_with_zeroes="${csv_file}.with_zeroes"
		if [[ -f "$csv_with_zeroes" ]] ; then
			echo "$0: csv $csv_with_zeroes present. Possibly already cleaned, so skipping" >&2
			rc=1

			continue
		fi

		mv "$csv_file" "$csv_with_zeroes"

		# Remove lines with x=0 or y=0
		sed -n -e '/^[^;][^;]*;[^;][^;]*;0;.*/d;/^[^;][^;]*;[^;][^;]*;[^;][^;]*;0;.*/d;p' \
			"$csv_with_zeroes" > "$csv_file" 

		diff "$csv_file" "$csv_with_zeroes" 1>/dev/null
		if [[ $? -eq 0 ]] ; then
# No zero coordinates, so restore original csv file
			mv --force "$csv_with_zeroes" "$csv_file" 
		elif [[ $? -eq 1 ]] ; then
			if [[ -n "$verbose" ]] ; then
				echo "$0: csv $csv_file has been cleaned from zero coordinates" >&2 
			fi
		else
			echo "$0: cleaning csv $csv_file from zero coordinates failed" >&2 
			rc=1
		fi

		i=$((i + 1))
	done

if [[ -n "$verbose" || -n "$debug" ]] ; then
	echo "" >&2
	echo "$0: number of csv files checked: $i" >&2
fi

if [[ $rc -ne 0 ]] ; then
	exit 1
fi
)

if [[ $? -ne 0 ]] ; then
	exit 1
fi

popd 1>/dev/null

exit 0
