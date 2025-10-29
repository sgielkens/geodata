#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-f] [-i input_file] [-v]


The options are as follows:
   -f   force overwriting output file
   -i   input file. This should be the Move3 Obs file
   -v   be verbose
EOF
	exit 1
}

unset force
unset verbose

while getopts ":fi:sv" option ; do
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

out_file="${input_file##*/}"
out_dir="${input_file%/*}"

if [[ "$out_dir" == "$out_file" ]] ; then
	out_dir="$(pwd)"
fi

out_name="${out_file%.out?}"
out_suf="${out_file##*.}"

move3_vereff_coors="${out_name}_${out_suf}_vereff_coors.txt"
if [[ -f "$move3_vereff_coors" ]] ; then
	if [[ -z $force ]] ; then
		echo "$0: Move3 file $move3_vereff_coors already exists, exiting" >&2
		exit 1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: overwriting Move3 file $move3_vereff_coors" >&2
	fi

	rm -f "$move3_vereff_coors"
	touch "$move3_vereff_coors"
fi


move3_toets_coors="${out_name}_${out_suf}_toets_coors.txt"
if [[ -f "$move3_toets_coors" ]] ; then
	if [[ -z $force ]] ; then
		echo "$0: Move3 file $move3_toets_coors already exists, exiting" >&2
		exit 1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: overwriting Move3 file $move3_toets_coors" >&2
	fi

	rm -f "$move3_toets_coors"
	touch "$move3_toets_coors"
fi

move3_toets_obs="${out_name}_${out_suf}_toets_obs.txt"
if [[ -f "$move3_toets_obs" ]] ; then
	if [[ -z $force ]] ; then
		echo "$0: Move3 file $move3_toets_obs already exists, exiting" >&2
		exit 1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: overwriting Move3 file $move3_toets_obs" >&2
	fi

	rm -f "$move3_toets_obs"
	touch "$move3_toets_obs"
fi

unset start
unset station

# Use option -r to keep \ from Windows paths
while read -r line ; do
	# Remove Windows carriage return
	line="${line//$'\r'}"

	if [[ -z $start ]] ; then
		if [[ "$line" =~ VEREFFENDE[[:space:]]COORDINATEN.* ]] ; then
			start='vereff_coors'
			filtered="$move3_vereff_coors"
		fi

		if [[ "$line" =~ TOETSING[[:space:]]VAN[[:space:]]BEKENDE[[:space:]]COORDINATEN.* ]] ; then
			start='toets_coors'
			filtered="$move3_toets_coors"
		fi

		if [[ "$line" =~ TOETSING[[:space:]]VAN[[:space:]]WAARNEMINGEN.* ]] ; then
			start='toets_obs'
			filtered="$move3_toets_obs"
		fi

		continue
	fi

	if [[ $start == 'vereff_coors' ]] ; then
		# For out1
		if [[ "$line" =~ EXTERNE[[:space:]]BETROUWBAARHEID.* ]] ; then
			unset start
			continue
		fi

		# For out2
		if [[ "$line" =~ TOETSING[[:space:]]VAN[[:space:]]BEKENDE[[:space:]]COORDINATEN.* ]] ; then
			start='toets_coors'
			filtered="$move3_toets_coors"

			continue
		fi

		naam="${line%% X*}"

		if [[ ! "$naam" == "$line" ]] ; then
			station="${naam%}"
		fi

		echo "$line" | sed -n -e 's/.m.//g;s/ X /_X_/;s/Y /'"$station"'_Y_/;s/Hoogte/'"$station"'_Hoogte/;s/  */;/g;s/;$//;p' >> "$filtered"
	fi

	if [[ $start == 'toets_coors' ]] ; then
		if [[ "$line" =~ EXTERNE[[:space:]]BETROUWBAARHEID.* ]] ; then
			unset start
			continue
		fi

		# s/\(\([^;]*;\)\{4\}\)\(.*\)/\1/ selects first 4 csv columns
		echo "$line" | sed -n -e 's/.m.//g;s/Gs fout.*//;s/ X /_X_/;s/ Y /_Y_/;s/ Hoogte /_Hoogte_/;s/  */;/g;s/\(\([^;]*;\)\{4\}\)\(.*\)/\1/;s/;$//;p' >> "$filtered"
	fi


	if [[ $start == 'toets_obs' ]] ; then
		if [[ "$line" =~ Station.* ]] ; then
			echo 'Richting;'"$line" | sed -n -e 's/Gs fout.*//;s/  */;/g;s/;$//;p' >> "$filtered"
			continue
		fi

		# s/\(\([^;]*;\)\{8\}\)\(.*\)/\1/ selects first 8 csv columns
		echo "$line" | sed -n -e 's/.m.//g;s/  */;/g;s/\(\([^;]*;\)\{8\}\)\(.*\)/\1/;s/;$//;p' >> "$filtered"
	fi

done < "${out_dir}/${out_file}"

exit 0
