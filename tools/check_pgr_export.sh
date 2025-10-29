#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-d] [-i input_dir] [-p pgr_dir] [-v]

Use this script to check if all Ladybug recordings have corresponding PGR files.

It reads from the input directory all subdirectories. These subdirectories
are assumed to be the recording directories of the Ladybug. Directories not
having the correct name pattern (YYYY_MM_DD_hh_mm_ss) are skipped.

Then it checks if these recording directories have one or more matching PGR files.

The options are as follows:
   -d   debugging output
   -i   input directory. By default current directory.
   -p   PGR directory. By default PGR in input directory.
   -v   be verbose
EOF
	exit 1
}

input_dir=$(pwd)

unset debug
unset verbose

while getopts ":di:p:v" option ; do
   case ${option} in
      "d") debug="yes"
           ;;
      "i") input_dir="${OPTARG}"
           ;;
      "p") pgr_dir="${OPTARG}"
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

if [[ -z "$pgr_dir" ]] ; then
	pgr_dir="$input_dir"'/PGR'
fi

if [[ ! -d "$pgr_dir" ]] ; then
	echo "$0: PGR directory $pgr_dir does not exist" >&2
	exit 1
fi

pushd "$pgr_dir" 1>/dev/null
pgr_dir="$( pwd )"
popd 1>/dev/null

tmp_dir=$(mktemp -d)
if [[ $? -ne 0 ]] ; then
	echo "$0: could not create temporary file" >&2
	exit 1
fi

tmp_pgr="${tmp_dir}/pgr_file"
record_list="${tmp_dir}/record.txt"

trap 'rm -fr $tmp_dir' EXIT

pushd "$input_dir" 1>/dev/null

find . -mindepth 1 -type d > "$record_list"

if [[ ! -s "$record_list" ]] ; then
	echo "$0: no recordings found" >&2
	exit 1
fi

rc=0
i=0
nr_pgr=0

while read record ; do 
	record="${record##*/}"

	if [[ -n "$verbose" ]] ; then
		echo "$0: checking recording: $record" >&2
	fi

	if [[ ! "$record" =~ ^...._.._.._.._.._..$ ]] ; then
		echo "$0: skipping unexpected recording format $record" >&2
		continue
	fi

	rm -f "$tmp_pgr"

	find "$pgr_dir" -name "${record}-*.pgr" > "$tmp_pgr"

	if [[ ! -s "$tmp_pgr" ]] ; then
		echo "$0: missing PGR file(s) for recording $record" >&2
		echo "" >&2
		rc=1
	fi

	if [[ -n "$debug" ]] ; then
		echo "$0: recording $record has the following PGR files" >&2
		cat "$tmp_pgr" >&2
		echo "" >&2
	fi

	nr_tmp_pgr=$(wc -l "$tmp_pgr" | cut -d ' ' -f 1)
	nr_pgr=$(( $nr_pgr + $nr_tmp_pgr ))

	i=$((i + 1))

done < "$record_list"

if [[ -n "$verbose" ]] ; then
	echo "" >&2
	echo "$0: number of recordings checked: $i" >&2
	echo "$0: number of matching PGR files: $nr_pgr" >&2
fi

popd 1>/dev/null

if [[ $rc -ne 0 ]] ; then
	exit 1
fi

exit 0
