#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-i input_dir] [-o output_file] [-v]

This script extracts information from TRK log files.
The input directory should contain the PegasusProject directories.
This is for performance reasons of network storage.

The options are as follows:
   -i   input directory. By default current directory.
   -o   output file. By default $output_file_name in current directory.
   -v   be verbose
EOF
	exit 1
}

input_dir=$(pwd)

number_seconds=$(date '+%s')
output_file_name="TRK_log_info.txt_$number_seconds"

unset verbose

while getopts ":i:o:v" option ; do
   case ${option} in
      "i") input_dir="${OPTARG}"
           ;;
      "o") output_file="${OPTARG}"
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

if [[ -z "$output_file" ]] ; then
	output_dir="$(pwd)"
	output_file="$output_dir/$output_file_name"
fi

output_dir="${output_file%/*}"
output_file_name="${output_file##*/}"

if [[ -f "$output_file" ]] ; then
	echo "$0: output file alreasdy exists" >&2
	exit 1
fi

if [[ ! -d "$output_dir" ]] ; then
	mkdir -p "$output_dir"
fi

echo 'Pegasus Project,job,PEF version,PEF license,TRK type,path' > "$output_file"

pushd "$input_dir" 1>/dev/null

find . -mindepth 3 -maxdepth 3 -type d -name 'Logs' | \
(
	while read i ; do 
		if [[ -n "$verbose" ]] ; then
			echo "$0: checking log directory:   $i"
		fi

		job_dir="${i%/Logs}"
		job_dir="${job_dir##*/}"
		
		job_extension="${job_dir##*.}"
		
		if [[ "$job_extension" != 'job' ]] ; then
		# Skip Logs directory from processing 
			continue
		fi
	
		job_name="${job_dir%.job}"
	
		pushd $i 1>/dev/null

		logfile=$(find . -name 'LeicaField*.log')
		PEF_version="$( head -n 1 "$logfile" | sed -n -e 's/.*\(v.*\)\r/\1/p' )"
		license="$( grep -m 1 'License.*Valid' "$logfile" | sed -n -e 's/.*License:.* \(.*\)\r/\1/p' )"

		# Several fldClient logs may exist
		logfile=$(find . -name 'fldClient*.log' -print -quit)
		TRK_type="$( grep -m 1 ' product:' "$logfile" | sed -n -e 's/.*product: \(.*\)\r/\1/p' )"

		popd 1>/dev/null

		project_dir="${i%/Logs}"
		project_dir="${project_dir%/*}"
		project_dir="${project_dir##*/}"
		
		project_name="${project_dir%.PegasusProject}"
		
		echo ${project_name},${job_name},${PEF_version},${license},${TRK_type},${input_dir}/${i} >> "$output_file"
	done

)

popd 1>/dev/null

exit 0