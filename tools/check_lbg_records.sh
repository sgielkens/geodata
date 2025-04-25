#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-d] [-i input_dir] [-v]

Use this script to check if all Ladybug recordings have the necessary files.

It reads from the input directory all subdirectories. These subdirectories
are assumed to be the recording directories of the Ladybug. Directories not
having the correct name pattern (YYYY_MM_DD_hh_mm_ss) are skipped.

The options are as follows:
   -d   debugging output
   -i   input directory. By default current directory.
   -v   be verbose
EOF
	exit 1
}

input_dir=$(pwd)

unset debug
unset verbose

while getopts ":di:v" option ; do
   case ${option} in
      "d") debug="yes"
           ;;
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

lbg_items=("Ladybug Grabber" "Serial NMEA Reader" "SystemState" "Triggerbox")
lbg_suffix=("dat" "idx")

find . -mindepth 1 -type d > "$tmp_file"

if [[ ! -s "$tmp_file" ]] ; then
	echo "$0: no recordings found" >&2
	exit 1
fi

rc=0
i=0

while read record ; do 
	record="${record##*/}"

	if [[ -n "$verbose" ]] ; then
		echo "$0: checking recording: $record" >&2
	fi

	if [[ ! "$record" =~ ^...._.._.._.._.._..$ ]] ; then
		echo "$0: skipping unexpected recording format $record" >&2
		continue
	fi

	j=0

	while [[ $j -lt ${#lbg_items[@]} ]] ; do

		k=0
		while [[ $k -lt ${#lbg_suffix[@]} ]] ; do
			if [[ -n "$debug" ]] ; then
				echo "$0: checking recording file: $record/${lbg_items[$j]}.${lbg_suffix[$k]}" >&2
			fi

			if [[ ! -f "$record/${lbg_items[$j]}.${lbg_suffix[$k]}" ]] ; then
				echo "$0: missing Ladybug item: $record/${lbg_items[$j]}.${lbg_suffix[$k]}" >&2
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
