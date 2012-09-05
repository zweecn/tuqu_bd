#!/bin/bash

date

local_pic="data/input/objs_local_path"
all="data/temp/dingxiang_mine_all_pinggu"
all_tmp="data/temp/all_pinggu_local.tmp"
all_out="data/temp/all_pinggu_local"

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($1, arr, "client");
#		file = "data" arr[2];
#		dest_dir[$2] = "data_tmp" arr[2];
#		split(file, arr2, "\\.");
#		obj_local[$2] = arr2[1];
#	} else {
#		if ( $1 in obj_local)
#			print $1 "\t" obj_local[$1] "\t" dest_dir[$1] "\t" $3 "\t" $4 "\t" $5 "\t" $6;
#	}
#}' $local_pic $all > $all_tmp

rm -rf $all_out
while read obj local_file dest_dir others
do
	if [ -f $local_file ]; then
		ex=`file ${local_file}.html | cut -d' ' -f2 |  awk '{
			if ($1 == "JPEG" || $1 == "JPG" || $1 == "PNG" || $1 == "GIF") 
				print tolower($1); 
			else 
				print "NOT_IMG"
		}'`	
		if [ $ex == "NOT_IMG" ]; then
			continue
		fi
		mkdir -p $dest_dir
		mv ${local}.${ex} $dest_dir	
		echo -e "${obj}\t${local_file}.${ex}\t${others}" >> $all_out
	fi
done < $all_tmp

date
echo "Finished."
