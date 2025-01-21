#!/usr/bin/bash

job_db_file='job.db'

usage()
{
   cat << EOF
usage: ${0##*/} [-j job_db] [-o output_dir] [-v]

This script adds the GPS week number to all csv files of a Pegasus job.
It uses the default job database job.db to extract the GPS week number.
It adds this to the csv files of the extenal orientation as a seperate column.

It needs as input the job.db file. The output directory
is the JPEG export directory at the level of the tracks, e.g.

foo.PegasusProject/Export/JPEG/bar.job


The options are as follows:
   -j   job.db file. By default job.db in the current directory.
   -o   output directory. By default current directory.
   -v   be verbose
EOF
	exit 1
}

input_dir="$(pwd)"
job_db="${input_dir}/$job_db_file"

output_dir="$(pwd)"

unset verbose

while getopts ":j:o:v" option ; do
   case ${option} in
      "j") job_db="${OPTARG}"
           ;;
      "o") output_dir="${OPTARG}"
           ;;
      "v") verbose="yes"
           ;;
      *) usage
         ;;
   esac
done


if [[ ! -e  "$job_db" ]] ; then
	echo "$0: job.db file $job_db does not exist" >&2
	exit 1
fi

if [[ ! -d "$output_dir" ]] ; then
	echo "$0: output directory $output_dir does not exist" >&2
	exit 1
fi

sqlite3_bin="$(which sqlite3)"

if [[ ! -x "$sqlite3_bin" ]] ; then
	echo "$0: command sqlite3 not found" >&2
	exit 1
fi

gps_week=$(echo 'select * from "JOB.SETTINGS"' | sqlite3 "$job_db" | sed -n -e 's/.*GPSWeek|\(.*\)/\1/p')
if [[ $? -ne 0 ]] ; then
	echo "$0: determination of GPS week failed" >&2
	exit 1
fi

if [[ -z "$gps_week" ]] ; then
	echo "$0: GPS week is empty" >&2
	exit 1
fi

pushd "$output_dir" 1>/dev/null

i=0

find . -name *.csv | \
(
	while read csv_file ; do
		if [[ -n "$verbose" ]] ; then
			echo "$0: adding GPS $gps_week week to $csv_file"
		fi

		csv_original="${csv_file}.leica"
		mv "$csv_file" "$csv_original"
		sed -n -e 's/;/;'$gps_week';/p' "$csv_original" > "$csv_file"

		i=$((i + 1))
	done

if [[ -n "$verbose" ]] ; then
	echo "" >&2
	echo "$0: number of csv files with added GPS week: $i" >&2
fi
)

popd 1>/dev/null

exit 0
