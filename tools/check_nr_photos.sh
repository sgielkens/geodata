#!/usr/bin/bash

scan_db_file='scan.db'
sphere_dir='Sphere'

usage()
{
   cat << EOF
usage: ${0##*/} [-e export_dir] [-j job_dir] [-v]

This script checks if for eacht track the number of exported JPEGs is equal
to the number of frames according to the scan.db. It does this only
for the Sphere images.

It needs as input the directory with exported JPEGs and the job directory.
The first one is at the level of the tracks, e.g.:

foo.PegasusProject/Export/JPEG/bar.job

That last one contains the scan directories Track*.scan.


The options are as follows:
   -e   JPEG export directory, containing the images per Track.
        By default th current directory.
   -j   Job directory, i.e. directory containing the scan directories.
        By default the current directory.
   -v   be verbose
EOF
	exit 1
}

export_dir="$(pwd)"
job_dir="$(pwd)"

unset debug
unset verbose

while getopts ":d:e:j:v" option ; do
   case ${option} in
      "d") debug="yes"
           ;;
      "e") export_dir="${OPTARG}"
           ;;
      "j") job_dir="${OPTARG}"
           ;;
      "v") verbose="yes"
           ;;
      *) usage
         ;;
   esac
done


if [[ ! -d "$export_dir" ]] ; then
	echo "$0: export directory $export_dir does not exist" >&2
	exit 1
fi

if [[ ! -d  "$job_dir" ]] ; then
	echo "$0: job direcotry $job_dir does not exist" >&2
	exit 1
fi

sqlite3_bin="$(which sqlite3)"

if [[ ! -x "$sqlite3_bin" ]] ; then
	echo "$0: command sqlite3 not found" >&2
	exit 1
fi

tmp_dir="$(mktemp -d)"
if [[ $? -ne 0 ]] ; then
	echo "$0: could not create temporary directory" >&2
	exit 1
fi

trap "rm -fr $tmp_dir" EXIT

track_list="${tmp_dir}/track.lst"

find . -maxdepth 1 -name 'Track*' > "$track_list"

if [[ ! -s "$track_list" ]] ; then
	echo "$0: no track directories found" >&2
	exit 1
fi

rc=0
i=0

while read track ; do
	if [[ ! -d "$track/$sphere_dir" ]] ; then
		echo "$0: track $track has no Sphere directory $track/$sphere_dir" >&2
		rc=1
	fi

	if [[ ! -d "$job_dir/$track.scan" ]] ; then
		echo "$0: track $track has no scan directory $job_dir/$track.scan" >&2
		rc=1
	fi

	if [[ ! -e "$job_dir/$track.scan/$scan_db_file" ]] ; then
		echo "$0: track $track has no scan.db $job_dir/$track.scan/$scan_db_file" >&2
		rc=1
	fi
	
	if [[ -n $verbose ]] ; then
		echo "$0: comparing export directory $track/$sphere_dir and scan.db $job_dir/$track.scan/$scan_db_file" >&2
	fi

	nr_jpegs=$(find "$track/$sphere_dir" -name '*.jpg' | wc -l)

	if [[ -z "$nr_jpegs" ]] ; then
		echo "$0: number of JPGEs is zero" >&2
		rc=1
	fi

	nr_frames=$(echo 'select * from "SCAN.SETTINGS"' | sqlite3 "$job_dir/$track.scan/$scan_db_file" | sed -n -e 's/.*countFrames|\(.*\)/\1/p')
	if [[ $? -ne 0 ]] ; then
		echo "$0: determination of number of frames failed" >&2
		rc=1
	fi
 
	if [[ -z "$nr_frames" ]] ; then
		echo "$0: number of frames is empty" >&2
		rc=1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: number of exported JPEGs $nr_jpegs and of frame count in scan.db $nr_frames" >&2
		echo "" >&2
	fi

	if [[ $nr_frames -ne $nr_jpegs ]] ; then
		echo "$0: mismatch between number of frames $nr_frames and number of JPEGs $nr_jpegs" >&2
		rc=1
	fi

	i=$((i + 1))

done < "$track_list"

if [[ -n "$verbose" ]] ; then
	echo "" >&2
	echo "$0: number of tracks checked: $i" >&2
fi

if [[ $rc -ne 0 ]] ; then
	exit 1
fi

exit 0
