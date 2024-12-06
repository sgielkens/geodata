#!/usr/bin/bash

RD_X_MIN='-7000'
RD_X_MAX='300000'

RD_Y_MIN='289000'
RD_Y_MAX='629000'

usage()
{
   cat << EOF
usage: ${0##*/} [-i input_dir] [-v]

This script checks if the coordinates of csv files have valid RD values, i.e.

$RD_X_MIN < x < $RD_X_MAX
$RD_Y_MIN < y < $RD_Y_MAX

Values are in meters. It searches recursively for csv files in the track directory.
It is assumed that the x and y coordinates are in columns 3 and 4 respectively.

The options are as follows:
   -i   input track directory. By default current directory.
   -v   be verbose
EOF
	exit 1
}

track_dir="$(pwd)"

unset verbose

while getopts ":i:v" option ; do
   case ${option} in
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
		if [[ -n "$verbose" ]] ; then
			echo "$0: checking RD coordinates for $csv_file"
		fi

		rd_x=$(sed -n -e 's/[^;][^;]*;[^;][^;]*;\([^;][^;]*\);.*/\1/p;q' "$csv_file") 
		rd_y=$(sed -n -e 's/[^;][^;]*;[^;][^;]*;[^;][^;]*;\([^;][^;]*\);.*/\1/p;q' "$csv_file") 

		rd_x_meter=${rd_x%.*}
		rd_y_meter=${rd_y%.*}

		if [[ "$rd_x_meter" -lt "$RD_X_MIN" || "$rd_x_meter" -gt "$RD_X_MAX" ]] ; then
			echo "$0: csv file: $csv_file" >&2
			echo "$0: RD x coordinate out of range: $rd_x_meter" >&2
			echo "" >&2
			rc=1
		fi

		if [[ "$rd_y_meter" -lt "$RD_Y_MIN" || "$rd_y_meter" -gt "$RD_Y_MAX" ]] ; then
			echo "$0: csv file: $csv_file" >&2
			echo "$0: RD y coordinate out of range: $rd_y_meter" >&2
			echo "" >&2
			rc=1
		fi

		i=$((i + 1))
	done

if [[ -n "$verbose" ]] ; then
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
