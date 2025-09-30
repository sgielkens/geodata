#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-f] [-i input_file] [-v]

Use this script to check if all Ladybug recordings have the necessary files.

It reads from the input directory all subdirectories. These subdirectories
are assumed to be the recording directories of the Ladybug. Directories not
having the correct name pattern (YYYY_MM_DD_hh_mm_ss) are skipped.

The options are as follows:
   -f   force overwriting output file
   -i   input file. This should be the Move3 Obs file
   -v   be verbose
EOF
	exit 1
}

unset force
unset verbose

while getopts ":fi:v" option ; do
   case ${option} in
      "f") force="yes"
           ;;
      "i") input_file="${OPTARG}"
           ;;
      "v") verbose="yes"
           ;;
      *) usage
         ;;
   esac
done

if [[ ! -f "$input_file" ]] ; then
	echo "$0: input file $input_file does not exist" >&2
	exit 1
fi

obs_file="${input_file##*/}"
obs_dir="${input_file%/*}"

obs_name="${obs_file%.Obs}"
move3_report="$obs_name.analysis"

if [[ -f "$move3_report" ]] ; then
	if [[ -z $force ]] ; then
		echo "$0: Move3 analysis report $move3_report already exists, exiting" >&2
		exit 1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: overwriting Move3 analysis report $move3_report" >&2
	fi
	rm -f "$move3_report"
fi

pushd "$obs_dir" 1>/dev/null

if [[ $? -ne 0 ]] ; then
	echo "$0: could not enter $obs_dir" >&2
	exit 42
fi

tmp_file=$(mktemp)
if [[ $? -ne 0 ]] ; then
	echo "$0: could not create temporary file" >&2
	exit 1
fi

trap 'rm -f $tmp_file' EXIT

touch "$move3_report"
i=0

#
# Filter and order Move3 observation file
#

# Use option -r to keep \ from Windows paths
while read -r id field1 field2 field3 field4 rest ; do
	if [[ "$id" == 'DH' ]] ; then
		if [[ $i -ne 0 ]] ; then
			echo "$0: unexpected order of DH and FL lines" >&2
			echo "${field1};${field2};${field3};${field4};" >&2
			exit 2
		fi

		from="$field1"
		to="$field2"
		DH="$field3"
		SH="$field4"

		i=1
	fi

	if [[ "$id" == 'FL' ]] ; then
		if [[ $i -ne 1 ]] ; then
			echo "$0: unexpected order of DH and FL lines" >&2
			echo "${field1};${field2};${field3};${field4};" >&2
			exit 2
		fi

		# GSI file and path may have spaces. These are separated by the read line
		gsi_file="$field2 $field3 $field4 $rest"
		gsi_file="${gsi_file##*\\}"
		# Remove Windows carriage return
		gsi_file="${gsi_file//$'\r'}"

		if [[ "$from" > "$to" ]] ; then
			temp_field="$from"
			from="$to"
			to="$temp_field"
		fi
		echo "${from};${to};${DH};${SH};$gsi_file" >> "$move3_report"
		i=0
	fi

done < "$obs_file"

sort "$move3_report" > "$tmp_file"
mv -f "$tmp_file" "$move3_report"

#
# Match back and forth data
#

move3_result="$move3_report.2"
touch "$move3_result"
echo "Van;Naar;DH-Heen;DH-Terug;SH-Heen;SH-Terug;Sluitfout;Tolerantie;Percentage;Voldoet;GSI-Heen;GSI-Terug" > "$move3_result"

non_standard=0
i=0

while IFS=';' read field1 field2 field3 field4 field5 ; do
	if [[ $i -eq 0 ]] ; then
		van="$field1"
		naar="$field2"
		dh_heen="$field3"
		sh_heen="$field4"
		gsi_heen="$field5"

		i=$((i + 1))
		continue
	fi

	if [[ $i -eq 1 ]] ; then
		if [[ "$field1" == "$van" ]] ; then
			dh_terug="$field3"
			sh_terug="$field4"
			gsi_terug="$field5"
		else
			dh_terug=0
			sh_terug=0
			gsi_terug='ENKEL OF DUBBEL'

			non_standard=1
		fi

		sluitfout=$(echo "scale=3 ; 1000 * ($dh_heen + $dh_terug)" | bc)
		lengte=$(echo "scale=3 ; ($sh_heen + $sh_terug) / 2000" | bc)

		tolerantie=$(echo "scale=3 ; 3 * sqrt($lengte)" | bc)
		percentage=$(echo "scale=3 ; 100 * $sluitfout / $tolerantie" | bc)

		voldoet=$(echo "scale=3 ; $sluitfout <= $tolerantie" | bc)
		if [[ $voldoet -eq 0 ]] ; then
			voldoet='***'
		else
			unset voldoet
		fi

		echo "${van};${naar};${dh_heen};${dh_terug};$sh_heen;$sh_terug;$sluitfout;$tolerantie;$percentage;$voldoet;$gsi_heen;$gsi_terug" >> "$move3_result"

		i=$((i + 1))

		if [[ $non_standard -eq 1 ]] ; then
			dh_heen="$field3"
			sh_heen="$field4"
			gsi_heen="$field5"

			non_standard=0
			i=0
		fi
		i=0
	fi
	
done < "$move3_report"

exit 0
