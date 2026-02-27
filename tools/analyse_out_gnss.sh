#!/usr/bin/bash

usage()
{
   cat << EOF
usage: ${0##*/} [-a] [-f] [-i input_file] [-v]

Use this script to extract information from the Move3 out files. These files
are actually the reports from the adjustment calculations in ASCII format.

The information extracted is primarily of interest to check compliance with
product specifications by RWS (Rijkswaterstaat). It generates several files:

1. <Move3 project>_out1_toets_obs.txt
2. <Move3 project>_out2_toets_coors.txt
3. <Move3 project>_out2_vereff_coors.txt


Ad 1. Among others, MDBs and BNRs from the free network adjustment
Ad 2. Among others, MDBs and BNRs from the pseudo least squares adjustment
Ad 3. Adjusted coordinates with standard deviation
      from the pseudo least squares adjustment

The options are as follows:
   -a   output all filtered reports
   -f   force overwriting output file
   -i   input file. This should be the Move3 out1 or out2 file.
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

move3_in_obs="${out_name}_${out_suf}_in_obs.txt"
if [[ -f "$move3_in_obs" ]] ; then
	if [[ -z $force ]] ; then
		echo "$0: Move3 file $move3_in_obs already exists, exiting" >&2
		exit 1
	fi

	if [[ -n "$verbose" ]] ; then
		echo "$0: overwriting Move3 file $move3_in_obs" >&2
	fi

	rm -f "$move3_in_obs"
	touch "$move3_in_obs"
fi

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
		if [[ "$line" =~ INVOER[[:space:]]WAARNEMINGEN.* ]] ; then
			if [[ -n $all ]] ; then
				start='in_obs'
				filtered="$move3_in_obs"
				i=0
			fi
		fi

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

	if [[ $start == 'in_obs' ]] ; then
		if [[ "$line" =~ INVOER[[:space:]]OVERIGE[[:space:]]PARAMETERS.* ]] ; then
			unset start

			continue
		fi

		if [[ "$line" =~ Centreerafwijking.* ]] ; then
			continue
		fi
		if [[ "$line" =~ Instrumenthoogte[[:space:]]afwijking.* ]] ; then
			continue
		fi

		if [[ "$line" =~ Station.* ]] ; then
			echo "Nr;Obs;Richting;Station;Status" >> "$filtered"

			i_obs=0
			unset arr_obs

			i=$((i+1))

			continue
		fi

		if [[ "${line:0:1}" == 'X' || "${line:0:2}" == 'DX' ]] ; then
			i_obs=$((i_obs + 1))
		fi

		unset status
		if [[ "$line" =~ .*desel ]] ; then
			status='desel'
			arr_obs[$i_obs]=$status
		fi

		# s/\(\([^;]*;\)\{4\}\)\(.*\)/\1/ selects first 4 csv columns
		echo "$i;$i_obs;$line" | sed -n -e 's/  */;/g;s/\(\([^;]*;\)\{4\}\)\(.*\)/\1/;s/;$/;'"$status"'/;p' >> "$filtered"

		i=$((i+1))
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
			line="${station};${line}"
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


		# s/\(\([^;]*;\)\{6\}\)\(.*\)/\1/ selects first 6 csv columns
		echo "$i;$line" | sed -n -e 's/X /X_/;s/Y /Y_/;s/  */;/g;s/\(\([^;]*;\)\{6\}\)\(.*\)/\1/;s/;$//;p' >> "$filtered"
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
			echo "Nr;Obs;Richting;$line" | sed -n -e 's/Gs fout.*//;s/MDB/MDB(m)/;s/  */;/g;s/;$//;p' >> "$filtered"

			i_obs=1
			k=0
			i=$((i+1))

			continue
		fi


		if [[ $k -eq 0 ]] ; then
			while [[ ${arr_obs[$i_obs]} == 'desel' ]] ; do
				i_obs=$((i_obs + 1))
			done
		fi

		# s/\(\([^;]*;\)\{10\}\)\(.*\)/\1/ selects first 10 csv columns
		echo "$i;$i_obs;$line" | sed -n -e 's/.m.//g;s/  */;/g;s/\(\([^;]*;\)\{10\}\)\(.*\)/\1/;s/;$//;p' >> "$filtered"

		k=$((k+1))
		if [[ $k -eq 3 ]] ; then
			k=0
			i_obs=$((i_obs + 1))
		fi

		i=$((i+1))
	fi

done < "${out_dir}/${out_file}"

exit 0
