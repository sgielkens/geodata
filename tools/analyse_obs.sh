#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-f] [-i input_file] [-v]

Use this script to check if all Ladybug recordings have the necessary files.

It reads from the input directory all subdirectories. These subdirectories
are assumed to be the recording directories of the Ladybug. Directories not
having the correct name pattern (YYYY_MM_DD_hh_mm_ss) are skipped.

The options are as follows:
   -f   force overwriting output file
   -i   input file. This should be the Move3 Obs file
   -v   be verbose
EOF
	exit 1
}

unset force
unset verbose

while getopts ":fi:v" option ; do
   case ${option} in
      "f") force="yes"
           ;;
      "i") input_file="${OPTARG}"
           ;;
      "v") verbose="yes"
           ;;
      *) usage
         ;;
   esac
done

if [[ ! -f "$input_file" ]] ; then
	echo "$0: input file $input_file does not exist" >&2
	exit 1
fi

obs_file="${input_file##*/}"
obs_dir="${input_file%/*}"

obs_name="${obs_file%.Obs}"
move3_report="$obs_name.analysis"

if [[ -f "$move3_report" ]] ; then
	if [[ -z $force ]] ; then
		echo "$0: Move3 analysis report $move3_report already exists, exiting" >&2
		exit 1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: overwriting Move3 analysis report $move3_report" >&2
	fi
	rm -f "$move3_report"
fi

pushd "$obs_dir" 1>/dev/null

if [[ $? -ne 0 ]] ; then
	echo "$0: could not enter $obs_dir" >&2
	exit 42
fi

tmp_file=$(mktemp)
if [[ $? -ne 0 ]] ; then
	echo "$0: could not create temporary file" >&2
	exit 1
fi

trap 'rm -f $tmp_file' EXIT

touch "$move3_report"
i=0

# Use option -r to keep \ from Windows paths
while read -r id field1 field2 field3 field4 rest ; do
	if [[ "$id" == 'DH' ]] ; then
		if [[ $i -ne 0 ]] ; then
			echo "$0: unexpected order of DH and FL lines" >&2
			echo "${field1};${field2};${field3};${field4};" >&2
			exit 2
		fi

		from="$field1"
		to="$field2"
		DH="$field3"
		SH="$field4"

		i=1
	fi

	if [[ "$id" == 'FL' ]] ; then
		if [[ $i -ne 1 ]] ; then
			echo "$0: unexpected order of DH and FL lines" >&2
			echo "${field1};${field2};${field3};${field4};" >&2
			exit 2
		fi

		# GSI file and path may have spaces. These are separated by the read line
		gsi_file="$field2 $field3 $field4 $rest"
		gsi_file="${gsi_file##*\\}"
		# Remove Windows carriage return
		gsi_file="${gsi_file//$'\r'}"

		echo "${from};${to};${DH};${SH};$gsi_file" >> "$move3_report"
		i=0
	fi

done < "$obs_file"

exit 0
