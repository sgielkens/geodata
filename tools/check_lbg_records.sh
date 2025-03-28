#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-i input_dir] [-v]

Use this script to check if all Ladybug recordings have the necessary files.

It reads in the input directory all subdirectories. These subdirectories
are assumed to be the recording directories of the Ladybug.

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

tmp_file=$(mktemp)
if [[ $? -ne 0 ]] ; then
	echo "$0: could not create temporary file" >&2
	exit 1
fi

trap 'rm -f $tmp_file' EXIT


pushd "$input_dir" 1>/dev/null

i=0
rc=0

lbg_items=("Ladybug Grabber" "Serial NMEA Reader" "SystemState" "Triggerbox")
lbg_suffix=("dat" "idx")

find . -type d > "$tmp_file"

rc=0
i=0

while read record ; do 
	if [[ -n "$verbose" ]] ; then
		echo "$0: checking recording: $record" >&2
	fi

	j=0

	while [[ $i -lt ${items[@]} ]] ; do

		k=0
		while [[ $k -lt ${lbg_suffix[@]} ]] ; do
			if [[ ! -f "$record/${item[$j]}.${lbg_suffix[$k]}" ]] ; then
				echo "$0: missing Ladybug item: $record/${item[$j]}.${lbg_suffix[$k]}" >&2	
				rc=1
			fi
			k=$((k + 1))
		done

	j=$((j + 1))

	done

	i=$((i + 1))

done < "$tmp_file"

if [[ -n "$verbose" ]] ; then
	echo "" >&2
	echo "$0: number of recordings checked: $i" >&2
fi

popd 1>/dev/null

if [[ $? -ne 0 ]] ; then
	exit 1
fi

exit 0
