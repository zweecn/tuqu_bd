#!/bin/bash

tag_dir="data/img09/objInfoByTag.20120901"
tag_1_dir="data/img09/objInfoByTag.1"
death_link="data/img09/death_link"
all_tmp="data/img09/all_tmp"
all="data/img09/all"

#rm $all_tmp
#while read tag
#do
#	tag_path="${tag_dir}/${tag}.txt"
#	tag_1_path="${tag_1_dir}/${tag}.txt"
#	awk -F '\t' '{
#		if ($4 == 1) {
#			print;	
#		}
#	}' $tag_path > ${tag_1_path}
#
#	cat $tag_1_path >> $all_tmp 
#
#done < conf/pinggu_res_tags
#
#
#sort -k1 $all_tmp | uniq > $all
#
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		site[$1] = 1;
#	} else {
#		for (s in site) {
#			if (index($0, s)) {
#				print;
#			}
#		}
#	}
#}' conf/death_site data/img09/all > $death_link

#objs_local="data/input/objs_local_path"
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		local_path[$2] = $1;
#	} else {
#		if (local_path[$1] != "") {
#			print local_path[$1];
#		}
#	}
#}' $objs_local $all > data/tmp/all_local_pics 
#
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		local_path[$2] = $1;
#	} else {
#		if (local_path[$1] != "") {
#			print local_path[$1];
#		}
#	}
#}' $objs_local $death_link > data/tmp/death_local_pics 

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		death[$1] = 1;
#	} else {
#		if (!($1 in death)) {
#			print;
#		}
#	}
#}' data/tmp/death_local_pics data/tmp/all_local_pics > data/tmp/all_without_death_pics

rm -rf data/img09/name_good_map
while read line
do
	echo $line
	dir="data/"`echo $line | awk -F '\t' '{
		split($1, arr, "client");
		print arr[2];
	}' | awk -F '/' '{
		print $2 "/" $3 "/" $4;
	}'`
	old_name="data"`echo $line | awk -F '\t' '{
		split($1, arr, "client");
		print arr[2];
	}'`
	
	mkdir -p $dir
	remote="img@jx-apptest-img04.vm.baidu.com:${line}"
	scp $remote $dir

	new_name=`echo $old_name | awk -F '.' '{print $1 ".";}'``file $old_name | cut -d' ' -f2 | awk '{print tolower($0);}'`
	mv $old_name $new_name
	echo $old_name $new_name >> data/img09/name_good_map	
done < data/tmp/all_without_death_pics

echo "Finished."
