#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-i input_dir] [-n num_cams] [-v]

This script checks for a job if:
- the number of txt files matches that of the csv files
- if there are txt files without matching csv file and vice verse

The options are as follows:
   -i   input directory. By default current directory.
   -n   number of cameras per track to take into account. Default is ${num_cams}, i.e.
        Front Left/Right, Left Backward/Forward,
        Rear Left/Right, Right Backward/Forward and Sphere
   -v   be verbose
EOF
	exit 1
}

input_dir="$(pwd)"
num_cams='9'

unset verbose

while getopts ":in::v" option ; do
   case ${option} in
      "i") input_dir="${OPTARG}"
           ;;
      "n") num_cams="${OPTARG}"
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

tmp_dir="$(mktemp -d)"
if [[ $? -ne 0 ]] ; then
	echo "$0: could not create temporary directory" >&2
	exit 1
fi

trap "rm -fr $tmp_dir" EXIT

txt_list="${tmp_dir}/txt.lst"
csv_list="${tmp_dir}/csv.lst"

pushd "$input_dir" 1>/dev/null

rc=0

find . -name '*.txt' | sed -n -e 's/\.txt//p' > "$txt_list"
find . -name '*.csv' | sed -n -e 's/\.csv//p' > "$csv_list"

if [[ ! -s "$txt_list" ]] ; then
	echo "$0: no txt files found" >&2
	exit 1
fi

if [[ ! -s "$csv_list" ]] ; then
	echo "$0: no csv files found" >&2
	exit 1
fi

# Use cat so wc reads from stdin. This prevents printing file names
count_txt=$(cat "$txt_list" | wc -l)
count_csv=$(cat "$csv_list" | wc -l)

if [[ -n $verbose ]] ; then
	echo "$0: number of txt files: $count_txt" >&2
	echo "$0: number of csv files: $count_csv" >&2
	echo "" >&2
fi

if [[ $count_txt -ne $count_csv ]] ; then
	echo "$0: number of txt files ($count_txt) not equal to number of csv files ($count_csv)" >&2
	rc=1
fi

txt_only="${tmp_dir}/txt_only"
csv_only="${tmp_dir}/csv_only"

comm -23 $txt_list $csv_list > "$txt_only"
comm -13 $txt_list $csv_list > "$csv_only"

if [[ -s "$txt_only" ]] ; then
	echo "$0: txt files without matching csv file" >&2
	cat "$txt_only" | sed -n -e 's/$/.txt/p' 1>&2
	echo "" >&2
	rc=1
fi

if [[ -s "$csv_only" ]] ; then
	echo "$0: csv files without matching txt file" >&2
	cat "$csv_only" | sed -n -e 's/$/.csv/p' 1>&2
	echo "" >&2
	rc=1
fi

i=0
j=0
while read regel ; do
	if [[ $j -eq 0 ]] ; then

		if [[ $regel =~ .*Track.*-.* ]] ; then
			if [[ $regel =~ .*Track.*-1.* ]] ; then
				i=$((i + 1))
			fi
		else
			i=$((i + 1))
		fi

		j=$num_cams
	fi
	j=$((j - 1))

	track_nr="${regel##*Track}"
	track_nr="${track_nr%%_*}"

	# In case a track is split, a suffix is added, e.g. g-1, 9-2
	track_nr="${track_nr%%-*}"

	# Strip leading 0 to prevent interpretation as octal (08) e.g.
	if [[ $i -ne ${track_nr#0} ]] ; then
		until [[ $i -eq ${track_nr#0} ]] ; do
			echo "$0: no txt file for track $i" >&2
			i=$((i + 1))
		done
		rc=1
	fi
done < "$txt_list"

i=0
j=0
while read regel ; do
	if [[ $j -eq 0 ]] ; then

		if [[ $regel =~ .*Track.*-.* ]] ; then
			if [[ $regel =~ .*Track.*-1.* ]] ; then
				i=$((i + 1))
			fi
		else
			i=$((i + 1))
		fi

		j=$num_cams
	fi
	j=$((j - 1))

	track_nr="${regel##*Track}"
	track_nr="${track_nr%_*}"

	# In case a track is split a suffix is added, e.g. 9-1, 9-2
	track_nr="${track_nr%-*}"

	# Strip leading 0 to prevent interpretation as octal (08) e.g.
	if [[ $i -ne ${track_nr#0} ]] ; then
		until [[ $i -eq ${track_nr#0} ]] ; do
			echo "$0: no csv file for track $i" >&2
			i=$((i + 1))
		done
		rc=1
	fi
done < "$csv_list"

if [[ $rc -ne 0 ]] ; then
	exit 1
fi

popd 1>/dev/null

exit 0
