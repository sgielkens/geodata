#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-f] [-i input_file] [-s] [-v]

This is an unfinished script for baselines. It is intended to be the equivalent
of analyse_obs.sh that handles leveling adjustment results of Move3.

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
while read -r id field1 field2 field3 field4 field5 rest ; do
	if [[ "$id" == 'DX' ]] ; then
		if [[ $i -ne 0 ]] ; then
			echo "$0: unexpected order of DX and FL lines" >&2
			echo "${id};${field1};${field2};${field3};${field4};${field5};" >&2
			exit 2
		fi

		from="$field1"
		to="$field2"
		DX="$field3"
		DY="$field4"
		DZ="$field5"

		i=1
	fi

	if [[ "$id" == 'FL' ]] ; then
		if [[ $i -ne 1 ]] ; then
			echo "$0: unexpected order of DX and FL lines" >&2
			echo "${id};${field1};${field2};${field3};${field4};${field5};" >&2
			exit 2
		fi

		# GSI file and path may have spaces. These are separated by the read line
		ski_file="$field2 $field3 $field4 $field5 $rest"
		ski_file="${ski_file##*\\}"
		# Remove Windows carriage return
		ski_file="${ski_file//$'\r'}"
		# and trailing blanks
		ski_file="${ski_file// }"

		if [[ "$from" > "$to" ]] ; then
			temp_field="$from"
			from="$to"
			to="$temp_field"
		fi

		if [[ ${DX: -1} == '#' ]] ; then
			if [[ -z "$skip" ]] ; then
				echo "${from};${to};${DX};${DY};${DZ};$ski_file" >> "$tmp_file"
			fi
		else
			echo "${from};${to};${DX};${DY};${DZ};$ski_file" >> "$tmp_file"
		fi

		i=0
	fi

done < "${obs_dir}/${obs_file}"

# Sort by from, to and GSI file to keep measurements together
sort -t ';' -k 1,2 -k 5 "$tmp_file" > "$move3_extract"

#
# Match back and forth data
#

echo "Van;Naar;DX-Heen;DX-Terug;DeltaX;DY-Heen;DY-Terug;DeltaY;DZ-Heen;DZ-Terug;DeltaZ;Sluitfout;Tolerantie;Verhouding;Voldoet;SKI-Heen;SKI-Terug" > "$move3_report"

non_standard=0
i=0

while IFS=';' read field1 field2 field3 field4 field5 field6 ; do
	if [[ $i -eq 0 ]] ; then
		van="$field1"
		naar="$field2"
		dx_heen="$field3"
		negatief=$(echo "scale=3 ; $dx_heen < 0" | bc)
		if [[ $negatief -eq 1 ]] ; then
			dx_heen=$(echo "scale=3 ; -1 * $dx_heen" | bc)
		fi

		dy_heen="$field4"
		negatief=$(echo "scale=3 ; $dy_heen < 0" | bc)
		if [[ $negatief -eq 1 ]] ; then
			dy_heen=$(echo "scale=3 ; -1 * $dy_heen" | bc)
		fi

		dz_heen="$field5"
		negatief=$(echo "scale=3 ; $dz_heen < 0" | bc)
		if [[ $negatief -eq 1 ]] ; then
			dz_heen=$(echo "scale=3 ; -1 * $dz_heen" | bc)
		fi

		ski_heen="$field6"

		i=1
		continue
	fi

	if [[ $i -eq 1 ]] ; then
		if [[ "$field1" == "$van" && "$field2" == "$naar" ]] ; then
			dx_terug="$field3"
			negatief=$(echo "scale=3 ; $dx_terug < 0" | bc)
			if [[ $negatief -eq 1 ]] ; then
				dx_terug=$(echo "scale=3 ; -1 * $dx_terug" | bc)
			fi

			dy_terug="$field4"
			negatief=$(echo "scale=3 ; $dy_terug < 0" | bc)
			if [[ $negatief -eq 1 ]] ; then
				dy_terug=$(echo "scale=3 ; -1 * $dy_terug" | bc)
			fi

			dz_terug="$field5"
			negatief=$(echo "scale=3 ; $dz_terug < 0" | bc)
			if [[ $negatief -eq 1 ]] ; then
				dz_terug=$(echo "scale=3 ; -1 * $dz_terug" | bc)
			fi

			ski_terug="$field6"

			i=0
		else
			dx_terug=0
			dy_terug=0
			dz_terug=0
			ski_terug='ENKEL'

			non_standard=1
		fi

		# Remove possible hash tag that Move3 appends to deselected observations
		delta_x=$(echo "scale=3 ; 100 * (${dx_heen%#} - ${dx_terug%#})" | bc)
		delta_y=$(echo "scale=3 ; 100 * (${dy_heen%#} - ${dy_terug%#})" | bc)
		delta_z=$(echo "scale=3 ; 100 * (${dz_heen%#} - ${dz_terug%#})" | bc)

#		lengte=$(echo "scale=3 ; ($dy_heen + $dy_terug) / 2000" | bc)

#		tolerantie=$(echo "scale=3 ; 3 * sqrt($lengte)" | bc)
#		verhouding=$(echo "scale=3 ; $sluitfout / $tolerantie" | bc)

#		voldoet=$(echo "scale=3 ; $sluitfout <= $tolerantie" | bc)
		if [[ $voldoet -eq 0 ]] ; then
			voldoet='X'
		else
			voldoet=''
		fi

		echo "${van};${naar};${dx_heen};${dx_terug};$delta_x;$dy_heen;$dy_terug;$delta_y;$dz_heen;$dz_terug;$delta_z;$sluitfout;$tolerantie;$verhouding;$voldoet;$gsi_heen;$gsi_terug" >> "$move3_report"

		if [[ $non_standard -eq 1 ]] ; then
			van="$field1"
			naar="$field2"
			dx_heen="$field3"
			negatief=$(echo "scale=3 ; $dx_heen < 0" | bc)
			if [[ $negatief -eq 1 ]] ; then
				dx_heen=$(echo "scale=3 ; -1 * $dx_heen" | bc)
			fi

			dy_heen="$field4"
			negatief=$(echo "scale=3 ; $dy_heen < 0" | bc)
			if [[ $negatief -eq 1 ]] ; then
				dy_heen=$(echo "scale=3 ; -1 * $dy_heen" | bc)
			fi

			dz_heen="$field5"
			negatief=$(echo "scale=3 ; $dz_heen < 0" | bc)
			if [[ $negatief -eq 1 ]] ; then
				dz_heen=$(echo "scale=3 ; -1 * $dz_heen" | bc)
			fi

			ski_heen="$field6"

			non_standard=0
		fi
	fi
	
done < "$move3_extract"

# Only back part has been read at end of file, forth is missing
if [[ $i -eq 1 ]] ; then
	dx_terug=0
	dy_terug=0
	dz_terug=0
	ski_terug='ENKEL'

	# Remove possible hash tag that Move3 appends to deselected observations
	delta_x=$(echo "scale=3 ; 100 * (${dx_heen%#} - ${dx_terug%#})" | bc)
	delta_y=$(echo "scale=3 ; 100 * (${dy_heen%#} - ${dy_terug%#})" | bc)
	delta_z=$(echo "scale=3 ; 100 * (${dz_heen%#} - ${dz_terug%#})" | bc)

#lengte=$(echo "scale=3 ; ($dy_heen + $dy_terug) / 2000" | bc)

#	tolerantie=$(echo "scale=3 ; 3 * sqrt($lengte)" | bc)
#	verhouding=$(echo "scale=3 ; $sluitfout / $tolerantie" | bc)

#	voldoet=$(echo "scale=3 ; $sluitfout <= $tolerantie" | bc)
	if [[ $voldoet -eq 0 ]] ; then
		voldoet='X'
	else
		voldoet=''
	fi

	echo "${van};${naar};${dx_heen};${dx_terug};$delta_x;$dy_heen;$dy_terug;$delta_y;$dz_heen;$dz_terug;$delta_z;$sluitfout;$tolerantie;$verhouding;$voldoet;$gsi_heen;$gsi_terug" >> "$move3_report"

fi

exit 0
