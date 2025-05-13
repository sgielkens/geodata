#!/usr/bin/bash

trk_proj_suf='PegasusProject'
lbg_record_suf='ec'

usage()
{
   cat << EOF
usage: ${0##*/} [-p trk_project] [-r ladybug_recordings] [-v] <connection>

Use this script to upload the necessary files from the TRK project and Ladybug
recordings to the online Geo-platform. It does this per job. As background tool
rclone is used.

To be able to upload connection details for the platform are needed. These are
stored in the rclone configuration file. This file had to be prepared before
involing this script. See the rclone documentation for details. Use the 
connection name in this configuration as <connection>.

Furthermore it needs both the TRK project directory and the associated directory
with Ladybug recordings. These can be explicitly set by the
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

geo_prefix='ingest'
geo_lidar='LiDAR'
geo_log='Log'
geo_pgr='PGR'
geo_traj='Trajectory'

unset debug
unset connection
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

shift $((OPTIND-1))

if [[ $# -ne 1 ]] ; then
	usage
fi

connection="$1"

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

rclone_bin="$(which rclone)"

if [[ ! -x "$rclone_bin" ]] ; then
	echo "$0: command rclone not found" >&2
	exit 1
fi

tmp_dir=$(mktemp -d)
if [[ $? -ne 0 ]] ; then
	echo "$0: could not create temporary directory" >&2
	exit 1
fi

trap 'rm -fr "$tmp_dir"' EXIT

pushd "$trk_proj" 1>/dev/null

find . -maxdepth 1 -name 'Job_*.job' > "${tmp_dir}/job.lst"

#
# TRK part
#
while read job ; do
	pushd "$job" >/dev/null

	if [[ ! -d 'Logs' ]] ; then
		echo "$0: job $job has no directory Logs" >&2
		exit 1
	fi
	if [[ ! -d 'Trajectory_ok/IE' ]] ; then
		echo "$0: job $job has no directory Trajectory_ok" >&2
		exit 1
	fi

	job_name="${job%.job}"

	if [[ -n "$verbose" ]] ; then
		echo "$0: uploading Leica Field log for job $job" >&2
	fi
	rclone copy --verbose Logs --include 'LeicaField_*' "$connection:$geo_prefix/${job_name}/$geo_log"

	if [[ -n "$verbose" ]] ; then
		echo "$0: uploading IE trajectory for job $job" >&2
	fi
	rclone copy --verbose Trajectory_ok/IE/ --include '*.cts' "$connection:$geo_prefix/${job_name}/$geo_traj"
	 
	if [[ -n "$verbose" ]] ; then
		echo "$0: uploading LiDAR data for job $job" >&2
	fi
	rclone copy --verbose . --include '*lidar*' "$connection:$geo_prefix/${job_name}/$geo_lidar"

	popd 1>/dev/null
done < "${tmp_dir}/job.lst"

popd 1>/dev/null

#
# Ladybug part
#
pushd "$lbg_record" 1>/dev/null

if [[ -n "$verbose" ]] ; then
	echo "$0: uploading mark4 data for job $job" >&2
fi
rclone copy --verbose ./mark4_ladybug_mapping.csv "$connection:$geo_prefix/${job_name}/$geo_pgr"

if [[ -n "$verbose" ]] ; then
	echo "$0: uploading PGR data for job $job" >&2
fi
rclone copy --verbose PGR "$connection:$geo_prefix/${job_name}/$geo_pgr"

popd 1>/dev/null

exit 0
