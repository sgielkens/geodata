#!/usr/bin/bash

scan_db_file='scan.db'

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

unset verbose

while getopts ":p:r:v" option ; do
   case ${option} in
      "p") trk_proj="${OPTARG}"
           ;;
      "r") lbg_record="${OPTARG}"
           ;;
      "v") verbose="yes"
           ;;
      *) usage
         ;;
   esac
done


if [[ ! -f  "$trk_proj" ]] ; then
	echo "$0: TRK project $trk_proj does not exist" >&2
	exit 1
fi

if [[ ! -f  "$lbg_record" ]] ; then
	echo "$0: Ladybug record $lbg_record does not exist" >&2
	exit 1
fi

sqlite3_bin="$(which sqlite3)"

if [[ ! -x "$sqlite3_bin" ]] ; then
	echo "$0: command sqlite3 not found" >&2
	exit 1
fi

tmp_dir=$(mktemp -d)
if [[ $? -ne 0 ]] ; then
	echo "$0: could not create temporary directory" >&2
	exit 1
fi

pushd "$trk_proj" 2>/dev/null

find . -maxdepth 1 -name 'Job_*.job' > "$tmp_dir/job.lst"

#
# TRK part
#
while read job ; do
	pushd "$job" >/dev/null

	find . -maxdepth 1 -name 'Track*.scan' | sed -e -n 's/^Track0*\(.*\).scan/\1/p' > "$tmp_dir/scan.lst"
	sort --numeric-sort "$tmp_dir/scan.lst" > "$tmp_dir/scan.sort"

	scan_first=$(head -n 1 "$tmp_dir/scan.sort")
	scan_last=$(tail -n 1 "$tmp_dir/scan.sort")

	if [[ -z "$scan_first" ]] ; then
		echo "$0: could not determine first scan of job $job" >&2
		exit 1
	fi

	if [[ -z "$scan_last" ]] ; then
		echo "$0: could not determine last scan of job $job" >&2
		exit 1
	fi


	if [[ $scan_first =~ [[:digit:]] ]] ; then
		scan_first_db='Track0'$scan_first'.scan/'$scan_db_file
	else
		scan_first_db='Track'$scan_first'.scan/'$scan_db_file
	fi

	if [[ $scan_last =~ [[:digit:]] ]] ; then
		scan_last_db='Track0'$scan_last'.scan/'$scan_db_file
	else
		scan_last_db='Track'$scan_last'.scan/'$scan_db_file
	fi


	echo 'select * from "SCAN.SETTINGS"' | \
		sqlite3 "$scan_first_db" | \
		sed -n -e 's/.*StartRecording|\(.*\)/\1/p' > "$tmp_dir/${job}_scan_first_start"

	if [[ $? -ne 0 ]] ; then
		echo "$0: determination of StartRecording failed in $scan_first_db" >&2
		exit 1
	fi

	if [[ ! -s "$tmp_dir/scan_first_start" ]] ; then
		echo "$0: empty StartRecording in $scan_first_db" >&2
		exit 1
	fi

	echo 'select * from "SCAN.SETTINGS"' | \
		sqlite3 "$scan_last_db" | \
		sed -n -e 's/.*StopRecording|\(.*\)/\1/p' > "$tmp_dir/${job}_scan_last_stop"

	if [[ $? -ne 0 ]] ; then
		echo "$0: determination of StopRecording failed in $scan_last_db" >&2
		exit 1
	fi

	if [[ ! -s "$tmp_dir/scan_last_stop" ]] ; then
		echo "$0: empty StopRecording in $scan_last_db" >&2
		exit 1
	fi

	popd >/dev/null
done < "$tmp_dir/job.lst"

popd >/dev/null

#
# Ladybug part
#
pushd "$lbg_record" >/dev/null

while read job ; do
	scan_first_start=$(< $tmp_dir/${job}_scan_first_start)
	scan_last_stop=$(< $tmp_dir/${job}_scan_last_stop)

	s
	
done < "$tmp_dir/job.lst"



popd 1>/dev/null

exit 0
