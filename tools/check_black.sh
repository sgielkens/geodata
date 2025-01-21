#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-i input_dir] [-v]

Use this script to check if a track has black only pictures. It checks only
the first picture found for a track. So it does not consider spheric and planar
cameras separately.

It needs as input directory the JPEG export directory at the level of the tracks, e.g.

foo.PegasusProject/Export/JPEG/bar.job

The options are as follows:
   -i   input directory. By default current directory.
   -v   be verbose
EOF
	exit 1
}

input_dir=$(pwd)

unset verbose

while getopts ":i:v" option ; do
   case ${option} in
      "i") input_dir="${OPTARG}"
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

convert_bin="$(which convert)"

if [[ ! -x "$convert_bin" ]] ; then
	echo "$0: command convert from ImageMagick not found" >&2
	exit 1
fi

pushd "$input_dir" 1>/dev/null

i=0
rc=0

find . -type d -name 'Track*' | \
(
	while read track ; do 
		if [[ -n "$verbose" ]] ; then
			echo "$0: checking Track: $track"
		fi

		pushd "$track" 1>/dev/null

		jpeg_file=$(find . -name '*.jpg' -print -quit)
		if [[ -z "$jpeg_file" ]] ; then
			echo "$0: no JPG found for track $track" >&2
			rc=1
		fi

		mean_jpg=$(convert "$jpeg_file" -format "%[mean]" info:)
		if [[ $? -ne 0 ]] ; then
			echo "$0: failed to determine the mean pixel value for $jpeg_file" >&2
			rc=1
		fi

		if [[ $mean_jpg = 0 ]] ; then
			echo "$0: track $track contains black only pictures" >&2
			rc=1
		fi

		i=$((i + 1))

		popd 1>/dev/null
	done

if [[ -n "$verbose" ]] ; then
	echo "" >&2
	echo "$0: number of tracks checked: $i" >&2
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
