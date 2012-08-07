#!/bin/bash
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
today=`date +%Y%m%d`

notype_input="./data/temp/pre_online.dingxiang.no_type"
out=${temp}.all_tags

#all_tags="conf/dingxiang_tag_list"
#
#awk -F'\t' '{
#	if (FILENAME == ARGV[1]) {
#		all_tags[$1] = 1;
#	} else {
#		if ($3 == "") {
#			next;
#		}
#		if ($3 in all_tags) {
#			next;
#		}
#		split($3, tags, ",");
#		for (i in tags) {
#			tag = tags[i];
#			if (!mark[tag]) {
#				print tag;
#				mark[tag] = 1;
#			}
#		}
#	}
#
#}' ${all_tags} ${notype_input} > ${out}

#awk '{
#	if (FILENAME == ARGV[1]) {
#		cnt[$1]++;
#	}
#	
#
#} END {
#	for (i in cnt) {
#		print i"\t"cnt[i];
#	}
#
#}' ${notype_input} > 1
