#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-m mapping_csv [-v]

This script removes from the so-called mapping csv file the entries in 
free run mode. These are the signals at 7 HZ or above.

The options are as follows:
   -f   frequency above which free run mode is supposed, by default $freq HZ
   -m   mapping csv. By default $mapping_csv_name in current directory.
   -v   be verbose
EOF
	exit 1
}

cur_dir="$(pwd)"
mapping_csv_name='mark4_ladybug_mapping.csv'
horus_suf='horus'

freq=7

csv_header='sec_of_week,week_nr,labybug_idx,sec_ladybug'

unset verbose
unset debug

while getopts ":f:m:v" option ; do
   case ${option} in
      "f") freq="${OPTARG}"
           ;;
      "m") mapping_csv_file="${OPTARG}"
           ;;
      "v") verbose="yes"
           ;;
      *) usage
         ;;
   esac
done

if [[ -z "$mapping_csv_file" ]] ; then
	mapping_csv_file="$cur_dir"/"$mapping_csv_name" 
fi

if [[ ! -f "$mapping_csv_file" ]] ; then
	echo "$0: mapping csv file $mapping_csv_file does not exist" >&2
	exit 1
fi

nr_lines=$(wc -l "$mapping_csv_file" | cut -f1 -d' ')
# Disregard header line
nr_lines=$(( nr_lines - 1 ))

mapping_horus_file="$mapping_csv_file"."$horus_suf"

if [[ -f "$mapping_horus_file" ]] ; then
	echo "$0: mapping horus file $mapping_horus_file present. Possibly already cleaned, so exiting" >&2
	exit 1
fi

mv "$mapping_csv_file" "$mapping_horus_file"
echo > "$mapping_csv_file"

i=0
rc=0
unset sec_of_week_1
unset sec_of_week_2

while read mapping ; do
	if [[ $i -eq 0 ]] ; then
		# remove CR character as input has CRLF EOL
		mapping=${mapping%?}

		if [[ "$mapping" != "$csv_header" ]] ; then
			echo "$0: first line of csv does not match expected header" >&2
			echo "$0: $csv_header" >&2
			echo "$0: found:" >&2
			echo "$0: $mapping" >&2
			exit 1
		fi

		echo $mapping >> $mapping_csv_file

		i=$((i + 1))
		continue
	fi

	if [[ $i -eq 1 ]] ; then
		sec_of_week_1="${mapping%%,*}"

		if [[ -z "$sec_of_week_1" ]] ; then
			echo "$0: no number of seconds found in line:" >&2
			echo "$0: $mapping" >&2
			exit 1
		fi

		# read second line
		i=$((i + 1))
		continue
	fi

	sec_of_week_2="${mapping%%,*}"

	if [[ -z "$sec_of_week_2" ]] ; then
		echo "$0: no number of seconds found in line:" >&2
		echo "$0: $mapping" >&2
		exit 1
	fi

	if [[ -n $verbose ]] ; then
		echo "$0: comparing line $((i-1)) and $i of $nr_lines" >&2
	fi

	# Calculate time difference of consecutive timestampt and
	# compare that with the interval at 7 Hz, i.e. free run mode
	free_run=$( echo "scale=3 ; ($sec_of_week_2 - $sec_of_week_1) < (1 / $freq)" | bc )
	if [[ $free_run -eq 0 ]] ; then
		echo $mapping >> $mapping_csv_file
	fi

	sec_of_week_1=$sec_of_week_2
	i=$((i + 1))

done < "$mapping_horus_file"

exit 0
