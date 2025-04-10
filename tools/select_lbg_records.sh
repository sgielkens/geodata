#!/usr/bin/bash

scan_db_file='scan.db'

trk_proj_suf='PegasusProject'
lbg_record_suf='ecordings'

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
with Ladybug recording directories. These can be explicitly set by the
relevant options. When one or both options are left empty, the script tries
to deduce the directory or directories.

The options are as follows:
   -d   show detailed debug information. This implies verbosity.
   -p   TRK project directory, i.e. the directory with suffix PegasusProject
        If left empty, it is constructed from the Ladybug record directory
        If option -r is also unset, it checks if the current directory
        is a TRK project or Ladybug record.
   -r   directory with Ladybug recording directories. These subdirs have
        timestamps as directory names.
        If left empty, it is constructed from the TRK project directory.
        If option -p is also unset, it checks if the current directory
        is a TRK project or Ladybug record.
   -v   be verbose
EOF
	exit 1
}

unset debug
unset verbose

while getopts ":p:dr:v" option ; do
   case ${option} in
      "d") debug='yes'
           ;;
      "p") trk_proj="${OPTARG}"
           ;;
      "r") lbg_record="${OPTARG}"
           ;;
      "v") verbose='yes'
           ;;
      *) usage
         ;;
   esac
done

if [[ -n "$debug" ]] ; then
	verbose='yes'
fi

trk_proj=${trk_proj%/}
lbg_record=${lbg_record%/}

if [[ -z "$trk_proj" && -z "$lbg_record" ]] ; then
	if [[ -n "$debug" ]] ; then
		echo "$0: checking if current directory is a TRK project or Ladybug record" >&2
	fi

	work_dir="$(pwd)"
	work_dir_suf="${work_dir##*[._]}"

	if [[ "$work_dir_suf" == "$trk_proj_suf" ]] ; then
		trk_proj="$work_dir"

		if [[ -n "$debug" ]] ; then
			echo "$0: deduced TRK project as $trk_proj" >&2
		fi
	elif [[ "${work_dir_suf#?}" == "$lbg_record_suf" ]] ; then
		lbg_record="$work_dir"

		if [[ -n "$debug" ]] ; then
			echo "$0: deduced Ladybug record as $lbg_record" >&2
		fi
	else
		echo "$0: could not determine TRK project and Ladybug record" >&2
		exit 1
	fi
fi

if [[ -z "${trk_proj}" ]] ; then
	if [[ -n "$debug" ]] ; then
		echo "$0: deducing TRK project" >&2
	fi

	if [[ -n "$lbg_record" ]] ; then
		lbg_record_path="${lbg_record%/*}"
		lbg_record_main="${lbg_record##*/}"
		lbg_record_main="${lbg_record_main%_[rR]$lbg_record_suf}"

		trk_proj="$lbg_record_path/$lbg_record_main.$trk_proj_suf"
	fi

	if [[ -n "$debug" ]] ; then
		echo "$0: deduced TRK project as $trk_proj" >&2
	fi
fi

if [[ -z "${lbg_record}" ]] ; then
	if [[ -n "$debug" ]] ; then
		echo "$0: deducing Ladybug record" >&2
	fi

	if [[ -n "$trk_proj" ]] ; then
		trk_proj_path="${trk_proj%/*}"
		trk_proj_main="${trk_proj##*/}"
		trk_proj_main="${trk_proj_main%.$trk_proj_suf}"

		lbg_record="$trk_proj_path/$trk_proj_main"'_r'"$lbg_record_suf"
		if [[ ! -d  "$lbg_record" ]] ; then
			lbg_record="$trk_proj_path/$trk_proj_main"'_R'"$lbg_record_suf"
		fi
	fi

	if [[ -n "$debug" ]] ; then
		echo "$0: deduced Ladybug record as $lbg_record" >&2
	fi
fi

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

pushd "$trk_proj" 1>/dev/null

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

	popd 1>/dev/null
done < "$tmp_dir/job.lst"

popd 1>/dev/null

#
# Ladybug part
#
pushd "$lbg_record" 1>/dev/null

# Convert YYYY,MM,DD,HH,MM,SS -> YYYY_MM_DD_HH_MM_SS
convert_date_trk () {
	date_elems="$1"

	if [[ -z "$date_elems" ]] ; then
	       echo "$0: empty input argument date_elems" >&2
	       exit 1
	fi

	date_str="$(echo "$date_elems" | \
		sed -n -e 's/,/:/g ; s/\([^:]\+\):\([^:]\+\):\([^:]\+\):\(.*\)/\1-\2-\3 \4/p')"

	date_str_conv="$(date -d "$date_str" '+%Y_%m_%d_%H_%M_%S')"

	if [[ -z "$date_str_conv" ]] ; then
	       echo "$0: could not convert date_str $date_elems" >&2
	       exit 1
	fi

	echo "$date_str_conv"
}

# Convert YYYY_MM_DD_HH_MM_SS -> YYYY-MM-DD HH:MM:SS
convert_date_lbg () {
	date_elems="$1"

	if [[ -z "$date_elems" ]] ; then
	       echo "$0: empty input argument date_elems" >&2
	       exit 1
	fi

	date_str_conv="$(echo "$date_elems" | \
		sed -n -e 's/_/:/g ; s/\([^:]\+\):\([^:]\+\):\([^:]\+\):\(.*\)/\1-\2-\3 \4/p')"

	if [[ -z "$date_str_conv" ]] ; then
	       echo "$0: could not convert date_str $date_elems" >&2
	       exit 1
	fi

	echo "$date_str_conv"
}

# Convert number of seconds -> HH:MM:SS
convert_secs () {
	nr_secs="$1"

	if [[ -z "$nr_secs" ]] ; then
	       echo "$0: empty input argument nr_secs" >&2
	       exit 1
	fi

	nr_hours=$(( $nr_secs / 3600 ))
	nr_mins=$(( ($nr_secs - 3600 * $nr_hours) / 60 ))
	nr_secs=$(( $nr_secs - 3600 * $nr_hours - 60 * $nr_mins ))

	echo "$nr_hours:$nr_mins:$nr_secs"
}

while read job ; do
	scan_first_start=$(< $tmp_dir/${job}_scan_first_start)
	scan_first_start=$(convert_date_trk "$scan_first_start")
	scan_first_start_year="${scan_first_start%%_*}"

	if [[ $? -ne 0 ]] ; then
		echo "$0: could determine scan_first_start for job $job" >&2
		exit 1
	fi
	if [[ -n "$verbose" ]] ; then
		echo "$0: first scan start time $scan_first_start" >&2
	fi

	scan_last_stop=$(< $tmp_dir/${job}_scan_last_stop)
	scan_last_stop=$(convert_date_trk "$scan_last_stop")
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

	echo "" >&2

	find . -mindepth 1 -maxdepth 1 -type d -name "${scan_first_start_year}*" -printf '%f\n' | \
		sort > "$tmp_dir/record.lst"

	while read record ; do
		if [[ "$record" < "$scan_first_start" ]] ; then
			echo "$0: recording $record starts before start first track of job $job" >&2
		fi

		if [[ "$record" > "$scan_last_stop" ]] ; then
			echo "$0: recording $record starts after stop last track of job $job" >&2
		fi
	done < "$tmp_dir/record.lst"

	record_first_start="$(head -n1 "$tmp_dir/record.lst")"
	record_first_start=$(convert_date_lbg "$record_first_start")
	record_first_start_s="$(date -d "$record_first_start" '+%s')"

	record_last_start="$(tail -n1 "$tmp_dir/record.lst")"
	record_last_start=$(convert_date_lbg "$record_last_start")
	record_last_start_s="$(date -d "$record_last_start" '+%s')"

	scan_first_start=$(convert_date_lbg "$scan_first_start")
	scan_first_start_s="$(date -d "$scan_first_start" '+%s')"

	scan_last_stop=$(convert_date_lbg "$scan_last_stop")
	scan_last_stop_s="$(date -d "$scan_last_stop" '+%s')"

	diff_scan_record_first="$(( $scan_first_start_s - $record_first_start_s ))"
	diff_scan_record_first="$(convert_secs "$diff_scan_record_first")"

	diff_scan_record_last="$(( $scan_last_stop_s - $record_last_start_s ))"
	diff_scan_record_last="$(convert_secs "$diff_scan_record_last")"

	echo "" >&2

	echo "Duration between start first track and start first record: $diff_scan_record_first" >&2
	echo "Duration between stop last track and start last record: $diff_scan_record_last" >&2

done < "$tmp_dir/job.lst"

popd 1>/dev/null

exit 0
