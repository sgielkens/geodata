#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-i input_dir] [-v]

This script removes empty images, i.e. images with size zero.

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

pushd "$input_dir" 1>/dev/null

unset rm_opts
if [[ -n "$verbose" ]] ; then
	rm_opts='--verbose'
fi

find . -type f -size 0 -exec rm $rm_opts {} \;

popd 1>/dev/null

exit 0
