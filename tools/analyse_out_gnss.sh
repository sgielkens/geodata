#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-a] [-f] [-i input_file] [-v]


The options are as follows:
   -a   output all filtered reports
   -f   force overwriting output file
   -i   input file. This should be the Move3 Obs file
   -v   be verbose
EOF
	exit 1
}

unset all
unset force
unset verbose

while getopts ":afi:v" option ; do
   case ${option} in
      "a") all="yes"
           ;;
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

move3_gnss_corrs="${out_name}_${out_suf}_gnss_corrs.txt"
if [[ -f "$move3_gnss_corrs" ]] ; then
	if [[ -z $force ]] ; then
		echo "$0: Move3 file $move3_gnss_corrs already exists, exiting" >&2
		exit 1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: overwriting Move3 file $move3_gnss_corrs" >&2
	fi

	rm -f "$move3_gnss_corrs"
	touch "$move3_gnss_corrs"
fi

move3_vereff_obs="${out_name}_${out_suf}_vereff_obs.txt"
if [[ -f "$move3_vereff_obs" ]] ; then
	if [[ -z $force ]] ; then
		echo "$0: Move3 file $move3_vereff_obs already exists, exiting" >&2
		exit 1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: overwriting Move3 file $move3_vereff_obs" >&2
	fi

	rm -f "$move3_vereff_obs"
	touch "$move3_vereff_obs"
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

	if [[ -z "$line" ]] ; then
		continue
	fi

	if [[ -z $start ]] ; then
		if [[ "$line" =~ VEREFFENDE[[:space:]]COORDINATEN.* ]] ; then
			if [[ -n $all || $out_suf == 'out2' ]] ; then
				start='vereff_coors'
				filtered="$move3_vereff_coors"
				i=0
			fi
		fi

		if [[ "$line" =~ TOETSING[[:space:]]VAN[[:space:]]BEKENDE[[:space:]]COORDINATEN.* ]] ; then
			if [[ -n $all || $out_suf == 'out2' ]] ; then
				start='toets_coors'
				filtered="$move3_toets_coors"
				i=0
			fi
		fi

		if [[ "$line" =~ GNSS/GPS[[:space:]]BASISLIJN[[:space:]]VECTOR[[:space:]]CORRECTIES.* ]] ; then
			if [[ -n $all ]] ; then
				start='gnss_corrs'
				filtered="$move3_gnss_corrs"
				i=0
			fi
		fi

		if [[ "$line" =~ VEREFFENDE[[:space:]]WAARNEMINGEN.* ]] ; then
			if [[ -n $all ]] ; then
				start='vereff_obs'
				filtered="$move3_vereff_obs"
				i=0
			fi
		fi

		if [[ "$line" =~ TOETSING[[:space:]]VAN[[:space:]]WAARNEMINGEN.* ]] ; then
			if [[ -n $all || $out_suf == 'out1' ]] ; then
				start='toets_obs'
				filtered="$move3_toets_obs"
				i=0
			fi
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
			i=0

			continue
		fi

		if [[ "$line" =~ Station.* ]] ; then
			echo "Nr;$line" | sed -n -e 's/Station/Station;Richting/;s/ (m)/(m)/g;s/  */;/g;s/;$//;p' >> "$filtered"
			i=$((i+1))

			continue
		fi


		naam="${line%% X*}"

		# only X direction contains station name
		if [[ ! "$naam" == "$line" ]] ; then
			station="${naam%}"
		else
			# so add it to Y and Z, unless line is empty (i.e. the one after the list)
#			if [[ -n "$line" ]] ; then
				line="${station};${line}"
#		#	fi
		fi

		echo "$i;$line" | sed -n -e 's/X /X_/;s/Y /Y_/;s/  */;/g;s/;$//;p' >> "$filtered"
		i=$((i+1))
	fi

	if [[ $start == 'toets_coors' ]] ; then
		if [[ "$line" =~ EXTERNE[[:space:]]BETROUWBAARHEID.* ]] ; then
			unset start
			i=0

			continue
		fi

		if [[ "$line" =~ Station.* ]] ; then
			echo "Nr;$line" | sed -n -e 's/Station/Station;Richting/;s/Gs fout.*//;s/ (m)/(m)/g;s/  */;/g;s/;$//;p' >> "$filtered"
			i=$((i+1))

			continue
		fi


		# s/\(\([^;]*;\)\{4\}\)\(.*\)/\1/ selects first 5 csv columns
		echo "$i;$line" | sed -n -e 's/X /X_/;s/Y /Y_/;s/  */;/g;s/\(\([^;]*;\)\{5\}\)\(.*\)/\1/;s/;$//;p' >> "$filtered"
		i=$((i+1))
	fi

	if [[ $start == 'gnss_corrs' ]] ; then
		if [[ "$line" =~ TOETSING[[:space:]]VAN[[:space:]]WAARNEMINGEN.* ]] ; then
			if [[ -n $all || $out_suf == 'out1' ]] ; then
				start='toets_obs'
				filtered="$move3_toets_obs"
				i=0
			else
				unset start
			fi

			continue
		fi

		if [[ "$line" =~ Station.* ]] ; then
			echo "Nr;Vector;$line" | sed -n -e 's/ vec/_vec/;s/ ppm/(ppm)/;s/  */;/g;s/;$//;p' >> "$filtered"
			i=$((i+1))

			continue
		fi

		echo "$i;$line" | sed -n -e 's/.ppm//g;s/  */;/g;s/;$//;p' >> "$filtered"
		i=$((i+1))
	fi


	if [[ $start == 'vereff_obs' ]] ; then
		if [[ "$line" =~ GNSS/GPS[[:space:]]BASISLIJN[[:space:]]VECTOR[[:space:]]CORRECTIES.* ]] ; then
			if [[ -n $all ]] ; then
				start='gnss_corrs'
				filtered="$move3_gnss_corrs"
				i=0
			else
				unset start
			fi

			continue
		fi

		if [[ "$line" =~ Station.* ]] ; then
			echo "Nr;Richting;$line" | sed -n -e 's/ wn/_wn/;s/Sa/Sa(m)/;s/  */;/g;s/;$//;p' >> "$filtered"
			i=$((i+1))

			continue
		fi

		echo "$i;$line" | sed -n -e 's/.m.//g;s/  */;/g;s/;$//;p' >> "$filtered"
		i=$((i+1))
	fi

	if [[ $start == 'toets_obs' ]] ; then
		if [[ "$line" =~ Station.* ]] ; then
			echo "Nr;Richting;$line" | sed -n -e 's/Gs fout.*//;s/MDB/MDB(m)/;s/  */;/g;s/;$//;p' >> "$filtered"
			i=$((i+1))

			continue
		fi

		# s/\(\([^;]*;\)\{8\}\)\(.*\)/\1/ selects first 8 csv columns
		echo "$i;$line" | sed -n -e 's/.m.//g;s/  */;/g;s/\(\([^;]*;\)\{8\}\)\(.*\)/\1/;s/;$//;p' >> "$filtered"
		i=$((i+1))
	fi

done < "${out_dir}/${out_file}"

exit 0
