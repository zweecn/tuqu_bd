#!/bin/bash

mine_all="data/bad_tag_data/pre_online.mine.tag_modified"
selected="data/bad_tag_data/selected_data"
no_pass_tag_out="data/bad_tag_data/no_pass"
tag_cnt="data/bad_tag_data/tag_cnt"
pinggu_out="data/bad_tag_data/pinggu/"
site="data/bad_tag_data/site"

no_pass_tag="conf/mine_no_pass_tags"
obj_black="conf/obj_black_list"

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		no_pass_tag[$1] = 1;
#	} else if (FILENAME == ARGV[2] || FILENAME == ARGV[3]) {
#		selected[$1] = 1;	
#	} else {
#		if ($1 in selected)
#			next;
#		split($3, tags, ",");
#		for (i in tags) {
#			tag = tags[i];
#			if (tag in no_pass_tag){
#				print;	
#				break;
#			}
#		}
#	}
#
#}' $no_pass_tag $selected ${obj_black} $mine_all > $no_pass_tag_out
#
#
#awk -F '\t' '{
#	split($3, tags, ",");
#	for (i in tags) {
#		tag = tags[i];
#		tag_cnt[tag]++;
#	}
#} END {
#	for (tag in tag_cnt) {
#		print tag "\t" tag_cnt[tag];
#	}
#}' $no_pass_tag_out | sort -n -k2 -r > $tag_cnt
#
#/bin/rm -rf $pinggu_out/*
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		no_pass_tag[$1] = 20;	
#	} else {
#		split($3, tags, ",");
#		for (i in tags) {
#			tag = tags[i];
#			if (tag in no_pass_tag ) {
#				print  > "'${pinggu_out}'"tag; 
#			}
#		}
#	}
#}' $no_pass_tag $no_pass_tag_out 
#

#all_tag=`ls $pinggu_out`
#for tag in $all_tag
#do
#	awk -F '\t' '{
#		print $1 "\t" $2 "\t" $3 "\t" rand();
#	}' $pinggu_out/$tag | sort -k4 -n | cut -f 1,2,3 | head -n 50 | sort -k1 > ${pinggu_out}/${tag}.rand50
#done

#sort -k2 $no_pass_tag_out > ${no_pass_tag_out}.sort

perl -lne '{
	if ($_ =~ /http.*?\/\/([^\/]+).*?http.*?\/\/([^\/]+)/) {
		print $2;
	}
}' ${no_pass_tag_out} | sort | uniq > $site  
