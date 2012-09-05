#!/bin/bash

tag_dir="data/img09/objInfoByTag.merge.0901"
tag_uniq_dir="data/img09/objInfoByTag.uniq"
uniq_md5="data/img09/uniq_md5_map"
uniq_objs_map="data/img09/uniq_objs_map"

all_tmp="data/img09/all_tmp"
all="data/img09/all"

#mkdir $tag_uniq_dir
#rm $all_tmp
#while read tag
#do
#	tag_path="${tag_dir}/${tag}.txt"
#	tag_uniq_path="${tag_uniq_dir}/${tag}.txt"
#	awk -F '\t' '{
#		if ($4 == 1) {
#			print;	
#		}
#	}' $tag_path > ${tag_uniq_path}
#
#	cat $tag_uniq_path >> $all_tmp 
#done < conf/pinggu_res_tags
#sort -k1 $all_tmp | uniq > $all

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		split($1, arr, "client");
		key = "data" arr[2];
		f[key] = $1;
		o[key] = $2;
	} else {
		print f[$1] "\t" o[$1] "\t" $2 "\t" $3;		
	}
}' data/input/objs_local_path $uniq_md5 > $uniq_objs_map 

echo "Finished."
