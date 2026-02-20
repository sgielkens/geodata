#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-f] [-i input_file] [-s] [-v]

Use this script to check leveling measurements.
It uses data from a Move3 project. To that end it is sufficient
to import the GSI files into the project.

The options are as follows:
   -f   force overwriting output file
   -i   input file. This should be the Move3 Obs file
   -s   skip deselected observations
   -v   be verbose
EOF
	exit 1
}

unset force
unset skip
unset verbose

while getopts ":fi:sv" option ; do
   case ${option} in
      "f") force="yes"
           ;;
      "i") input_file="${OPTARG}"
           ;;
      "s") skip="yes"
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

if [[ "$obs_dir" == "$obs_file" ]] ; then
	obs_dir="$(pwd)"
fi

obs_name="${obs_file%.Obs}"

move3_report="$obs_name.report.csv"
move3_extract="$obs_name.extract.csv"

if [[ -f "$move3_extract" ]] ; then
	if [[ -z $force ]] ; then
		echo "$0: Move3 extract file $move3_extract already exists, exiting" >&2
		exit 1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: overwriting Move3 extract file $move3_extract" >&2
	fi
	rm -f "$move3_extract"
fi

#pushd "$obs_dir" 1>/dev/null

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

i=0

#
# Filter and order Move3 observation file
#

# Use option -r to keep \ from Windows paths
while read -r id field1 field2 field3 field4 rest ; do
	if [[ "$id" == 'DH' ]] ; then
		if [[ $i -ne 0 ]] ; then
			echo "$0: unexpected order of DH and FL lines" >&2
			echo "${id};${field1};${field2};${field3};${field4};" >&2
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
			echo "${id};${field1};${field2};${field3};${field4};" >&2
			exit 2
		fi

		# GSI file and path may have spaces. These are separated by the read line
		gsi_file="$field2 $field3 $field4 $rest"
		gsi_file="${gsi_file##*\\}"
		# Remove Windows carriage return
		gsi_file="${gsi_file//$'\r'}"
		# and trailing blanks
		gsi_file="${gsi_file// }"

		if [[ "$from" > "$to" ]] ; then
			temp_field="$from"
			from="$to"
			to="$temp_field"
		fi

		if [[ ${DH: -1} == '#' ]] ; then
			if [[ -z "$skip" ]] ; then
				echo "${from};${to};${DH};${SH};$gsi_file" >> "$tmp_file"
			fi
		else
			echo "${from};${to};${DH};${SH};$gsi_file" >> "$tmp_file"
		fi

		i=0
	fi

done < "${obs_dir}/${obs_file}"

# Sort by from, to and GSI file to keep measurements together
sort -t ';' -k 1,2 -k 5 "$tmp_file" > "$move3_extract"

#
# Match back and forth data
#

echo "Van;Naar;DH-Heen;DH-Terug;SH-Heen;SH-Terug;Sluitfout;Tolerantie;Verhouding;Voldoet;GSI-Heen;GSI-Terug" > "$move3_report"

non_standard=0
i=0

while IFS=';' read field1 field2 field3 field4 field5 ; do
	if [[ $i -eq 0 ]] ; then
		van="$field1"
		naar="$field2"
		dh_heen="$field3"
		sh_heen="$field4"
		gsi_heen="$field5"

		i=1
		continue
	fi

	if [[ $i -eq 1 ]] ; then
		if [[ "$field1" == "$van" && "$field2" == "$naar" ]] ; then
			dh_terug="$field3"
			sh_terug="$field4"
			gsi_terug="$field5"

			i=0
		else
			dh_terug=0
			sh_terug=0
			gsi_terug='ENKEL'

			non_standard=1
		fi

		# Remove possible hash tag that Move3 appends to deselected observations
		sluitfout=$(echo "scale=3 ; 1000 * (${dh_heen%#} + ${dh_terug%#})" | bc)

		negatief=$(echo "scale=3 ; $sluitfout < 0" | bc)
		if [[ $negatief -eq 1 ]] ; then
			sluitfout=$(echo "scale=3 ; -1 * $sluitfout" | bc)
		fi

		lengte=$(echo "scale=3 ; ($sh_heen + $sh_terug) / 2000" | bc)

		tolerantie=$(echo "scale=3 ; 3 * sqrt($lengte)" | bc)
		verhouding=$(echo "scale=3 ; $sluitfout / $tolerantie" | bc)

		voldoet=$(echo "scale=3 ; $sluitfout <= $tolerantie" | bc)
		if [[ $voldoet -eq 0 ]] ; then
			voldoet='X'
		else
			voldoet=''
		fi

		echo "${van};${naar};${dh_heen};${dh_terug};$sh_heen;$sh_terug;$sluitfout;$tolerantie;$verhouding;$voldoet;$gsi_heen;$gsi_terug" >> "$move3_report"

		if [[ $non_standard -eq 1 ]] ; then
			van="$field1"
			naar="$field2"
			dh_heen="$field3"
			sh_heen="$field4"
			gsi_heen="$field5"

			non_standard=0
		fi
	fi
	
done < "$move3_extract"

# Only back part has been read at end of file, forth is missing
if [[ $i -eq 1 ]] ; then
	dh_terug=0
	sh_terug=0
	gsi_terug='ENKEL'

	# Remove possible hash tag that Move3 appends to deselected observations
	sluitfout=$(echo "scale=3 ; 1000 * (${dh_heen%#} + ${dh_terug%#})" | bc)

	negatief=$(echo "scale=3 ; $sluitfout < 0" | bc)
	if [[ $negatief -eq 1 ]] ; then
		sluitfout=$(echo "scale=3 ; -1 * $sluitfout" | bc)
	fi

	lengte=$(echo "scale=3 ; ($sh_heen + $sh_terug) / 2000" | bc)

	tolerantie=$(echo "scale=3 ; 3 * sqrt($lengte)" | bc)
	verhouding=$(echo "scale=3 ; $sluitfout / $tolerantie" | bc)

	voldoet=$(echo "scale=3 ; $sluitfout <= $tolerantie" | bc)
	if [[ $voldoet -eq 0 ]] ; then
		voldoet='X'
	else
		voldoet=''
	fi

	echo "${van};${naar};${dh_heen};${dh_terug};$sh_heen;$sh_terug;$sluitfout;$tolerantie;$verhouding;$voldoet;$gsi_heen;$gsi_terug" >> "$move3_report"

fi

exit 0
