#!/bin/bash

tag_dir="data/img09/objInfoByTag.merge.0901"
tag_1_dir="data/img09/objInfoByTag.tag.1"
tag_o_dir="data/img09/objInfoByTag.tag.o"

death_link="data/img09/death_link"
all_tmp="data/img09/all_tmp"
all="data/img09/all"
objs_map="data/img09/objs_map"

#echo "Begin filter 0 result.."
#rm -rf $tag_1_dir
#mkdir $tag_1_dir
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
#sort -k1 $all_tmp | uniq > $all

#echo "Begin stat tags cnt..."
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

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($5, tags, "\\$\\$");
#		for ( i in tags) {
#			tag = tags[i];
#			tag_cnt[tag]++;
#		}
#	} else {
#		print $1 "\t" tag_cnt[$1];	
#	}
#}' $all conf/pinggu_res_tags > data/img09/all.txt

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($5, tags, "\\$\\$");
#		for ( i in tags) {
#			tag = tags[i];
#			tag_cnt[tag]++;
#		}
#	} else {
#		print $1 "\t" tag_cnt[$1];	
#	}
#}' $death_link conf/pinggu_res_tags > data/img09/death_link.txt

#good="data/img09/good"
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		death[$1] = 1;
#	} else {
#		if ($1 in death)
#			next;
#		print;
#	}
#}' $death_link $all > $good
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($5, tags, "\\$\\$");
#		for ( i in tags) {
#			tag = tags[i];
#			tag_cnt[tag]++;
#		}
#	} else {
#		print $1 "\t" tag_cnt[$1];	
#	}
#}' $good conf/pinggu_res_tags > data/img09/good.txt

#echo "Make new pinggu..."
#rm -rf $tag_o_dir
#mkdir -p $tag_o_dir
#while read tag
#do
#	tag_1_path="${tag_1_dir}/${tag}.txt"
#	tag_o_path="${tag_o_dir}/${tag}.txt"
#	echo $tag_1_path
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			objs[$2] = $3;	
#		} else if (FILENAME == ARGV[2]) {
#			death[$1] = 1;
#		} else {
#			if ($1 in death)
#				next;
#			if ($2 in objs)
#				print $1 "\t" objs[$2] "\t" $3 "\t" $4 "\t" $5 "\t" $6; 
#			else 
#				print > "data/img09/no_local_link";
#		}
#	}' $objs_map $death_link $tag_1_path > ${tag_o_path}
#
#done < conf/pinggu_res_tags

good="data/img09/good"
cat data/img09/objInfoByTag.filter/* | sort | uniq > $good 
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		split($5, tags, "\\$\\$");
		for ( i in tags) {
			tag = tags[i];
			tag_cnt[tag]++;
		}
	} else {
		print $1 "\t" tag_cnt[$1];	
	}
}' $good conf/pinggu_res_tags > data/img09/good.txt

echo "Finished."
