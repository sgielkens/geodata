#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-a] [-i input_dir] [-r] [-v]

Use this script to check if LAS/LAZ files have the wrong file
signature, aka magic number. For LAS/LAZ files this number is the four first 
bytes of the file. As printable characters this sould be 'LASF'.

It searches for files with suffix .las or .laz. To check any file use option -a.

The options are as follows:
   -a   check any file not only *.las and *.laz 
   -i   input directory. By default current directory.
   -r   search recursively
   -v   be verbose
EOF
	exit 1
}

input_dir=$(pwd)

unset all
unset recursive
unset verbose

while getopts ":ai:rv" option ; do
   case ${option} in
      "a") all="yes"
           ;;
      "i") input_dir="${OPTARG}"
           ;;
      "r") recursive="yes"
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

pushd "$input_dir" 1>/dev/null

i=0
rc=0

unset find_opts
if [[ -z "$recursive" ]] ; then
	find_opts="-maxdepth 1"
fi

find_opts="$find_opts -type f"

if [[ -z "$all" ]] ; then
	find_opts="$find_opts -name "'"*.las"'" -o -name "'"*.laz"'
fi

echo $find_opts | xargs find . | \
(
	while read las_file ; do 
		if [[ -n "$verbose" ]] ; then
			echo "$0: checking LAS/LAZ file: $las_file"
		fi

		signature=$(od --read-bytes=4 --address-radix=n --format=c "$las_file" )
		if [[ $? -ne 0 ]] ; then
			echo "$0: failed to determine the file signature for LAS/LAZ file $las_file" >&2
			rc=1
		fi

		# Remove whitespaces
		signature="${signature// /}"
		if [[ $signature != 'LASF' ]] ; then
			echo "$0: LAS/LAZ file $las_file has wrong signature $signature" >&2
			rc=1
		fi

		i=$((i + 1))
	done

if [[ -n "$verbose" ]] ; then
	echo "" >&2
	echo "$0: number of LAS/LAZ files checked: $i" >&2
fi

if [[ $rc -ne 0 ]] ; then
	exit 1
fi
)

if [[ $? -ne 0 ]] ; then
	exit 1
fi

popd 1>/dev/null

exit 0
