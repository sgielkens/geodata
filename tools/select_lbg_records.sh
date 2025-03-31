#!/usr/bin/bash

scan_db_file='scan.db'

usage()
{
   cat << EOF
usage: ${0##*/} [-p trk_project] [-r ladybug_recordings] [-v]

This script determines the start time of the first track and the stop time
of the last track of a TRK project. It does this per job.

Then it compares these timestamps with the directory names of the
Ladybug recordings. Those names are timestamps themselves.
Directories that fall outside of the range determined by
the start and stop times of the tracks are displayed.

It needs both the TRK project directory and the associated directory
with Ladybug recording directories.

The options are as follows:
   -p   TRK project directory, i.e. the directory with suffix PegasusProject
   -r   directory with Ladybug recording directories. These subdirs have
        timestamps as directory names
   -v   be verbose
EOF
	exit 1
}

trk_proj="$(pwd)"
lbg_record="$(pwd)"

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


if [[ ! -d  "$trk_proj" ]] ; then
	echo "$0: TRK project $trk_proj does not exist" >&2
	exit 1
fi

if [[ ! -d  "$lbg_record" ]] ; then
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

trap 'rm -fr "$tmp_dir"' EXIT

pushd "$trk_proj" 2>/dev/null

find . -maxdepth 1 -name 'Job_*.job' > "$tmp_dir/job.lst"

#
# TRK part
#
while read job ; do
	if [[ -n "$verbose" ]] ; then
		echo "$0: determining time range of scans in job $job" >&2
	fi

	pushd "$job" >/dev/null

	find . -maxdepth 1 -name 'Track*.scan'  -printf '%f\n' | \
		sed -n -e 's/^Track0*\(.*\).scan/\1/p' > "$tmp_dir/scan.lst"

	sort --numeric-sort "$tmp_dir/scan.lst" > "$tmp_dir/scan.sort"

	scan_first=$(head -n 1 "$tmp_dir/scan.sort")
	scan_last=$(tail -n 1 "$tmp_dir/scan.sort")

	if [[ -z "$scan_first" ]] ; then
		echo "$0: could not determine first scan of job $job" >&2
		exit 1
	fi
	if [[ -n "$verbose" ]] ; then
		echo "$0: first scan $scan_first" >&2
	fi


	if [[ -z "$scan_last" ]] ; then
		echo "$0: could not determine last scan of job $job" >&2
		exit 1
	fi
	if [[ -n "$verbose" ]] ; then
		echo "$0: last scan $scan_last" >&2
	fi


	if [[ $scan_first =~ ^[[:digit:]]$ ]] ; then
		scan_first_db='Track0'$scan_first'.scan/'$scan_db_file
	else
		scan_first_db='Track'$scan_first'.scan/'$scan_db_file
	fi

	if [[ $scan_last =~ ^[[:digit:]]$ ]] ; then
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

	if [[ ! -s "$tmp_dir/${job}_scan_first_start" ]] ; then
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

	if [[ ! -s "$tmp_dir/${job}_scan_last_stop" ]] ; then
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

convert_date () {
	date_elems="$1"

	if [[ -z "$date_elems" ]] ; then
	       echo "$0: empty input argument date_elems" >&2
	       exit 1
	fi

	date_str="$(echo "$date_elems" | \
		sed -n -e 's/,/:/g ; s/\([^:]\+\):\([^:]\+\):\([^:]\+\):\(.*\)/\1-\2-\3 \4/p')"

	date_str_conv="$(date -d "$date_str" '+%Y_%m_%d_%H_%M_%S')"

	if [[ -z "$date_str_conv" ]] ; then
	       echo "$0: could not convert date_str $date_str" >&2
	       exit 1
	fi

	echo "$date_str_conv"
}

while read job ; do
	scan_first_start=$(< $tmp_dir/${job}_scan_first_start)
	scan_first_start=$(convert_date "$scan_first_start")
	scan_first_start_year="${scan_first_start%%_*}"

	if [[ $? -ne 0 ]] ; then
		echo "$0: could determine scan_first_start for job $job" >&2
		exit 1
	fi
	if [[ -n "$verbose" ]] ; then
		echo "$0: first scan start time $scan_first_start" >&2
	fi

	scan_last_stop=$(< $tmp_dir/${job}_scan_last_stop)
	scan_last_stop=$(convert_date "$scan_last_stop")
	scan_last_stop_year="${scan_last_stop%%_*}"
	
	if [[ $? -ne 0 ]] ; then
		echo "$0: could determine scan_last_stop for job $job" >&2
		exit 1
	fi
	if [[ -n "$verbose" ]] ; then
		echo "$0: last scan stop time $scan_last_stop" >&2
	fi

	if [[ "$scan_first_start_year" != "$scan_last_stop_year" ]] ; then
		echo "$0: mismatch of year in scan_first_start $scan_first_start_year and scan_last_stop $scan_last_stop_year"
		exit 1
	fi

	find . -mindepth 1 -maxdepth 1 -type d -name "${scan_first_start_year}*" -printf '%f\n' |
		while read record ; do
			if [[ "$record" < "$scan_first_start" ]] ; then
				echo "$0: recording $record start before start first track of job $job" >&2
			fi

			if [[ "$record" > "$scan_last_stop" ]] ; then
				echo "$0: recording $record start after stop last track of job $job" >&2
			fi
		done

done < "$tmp_dir/job.lst"

popd 1>/dev/null

exit 0
