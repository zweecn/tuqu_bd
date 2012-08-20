#!/bin/bash

normalized="data/swap/dingxiang_data_normalized"
clean_tag="data/temp/pre_online.dingxiang.clean_tag"

valid="data/temp/pre_online.dingxiang.filter_tags"

conflict="data/temp/pre_online.dingxiang.type_conflict"
no_type="data/temp/pre_online.dingxiang.no_type"
no_tag="data/temp/pre_online.dingxiang.no_tag"

site_out="data/temp/dingxiang_site"
site_cnt_out="data/temp/dingxiang_site_cnt"
type_cnt_out="data/temp/dingxiang_type_cnt"
site_type_out="data/temp/dingxiang_site_type"
out="data/temp/dingxiang_out"
out_with_no_tag="data/temp/dingxiang_out_with_no_tag"


#perl -lne '{
#	if ($_ =~ /http.*?\/\/([^\/]+).*?http.*?\/\/([^\/]+)/) {
#		if ($2 =~ /(\w+\.\w+)$/) {
#			print $1;
#		}
#	}
#
#}' $normalized | sort | uniq > $site_out 
#
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		site[$1] = 1;
#	} else {
#		for (s in site) {
#			if (index($2, s)) {
#				site_cnt[s]++;
#				break;
#			}
#		}
#	}
#
#} END {
#	for (s in site_cnt) {
#		print s"\t"site_cnt[s];
#	}
#}' $site_out $normalized > $site_cnt_out 
#
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($NF, arr, "-");	
#		type = arr[2];	
#		site = arr[1];
#		print > "data/temp/"site;
#	}
#}' ${valid}
#
##awk -f '\t' '{
##	if (filename == argv[1]) {
##		print "data/temp/"$1;
##	} 
##}' $site_out > ${site_out}.path
#
#
#awk -F '\t' '{
#	type_cnt[$NF]++;	
#} END {
#	for (type in type_cnt) {
#		print type "\t" type_cnt[type]; 
#	}
#}' ${valid} > ${type_cnt_out}
#
#
#awk -F '\t' '{
#	split($1, arr, "-");
#	site = arr[1];
#	type = arr[2];
#	if (types[site] == "")
#		types[site] = type;
#	else 
#		types[site] = types[site] "," type;
#	cnt[site] += $2;
#} END {
#	for (site in types) {
#		print site "\t" types[site] "\t" cnt[site];
#	}
#}' ${type_cnt_out} > ${site_type_out}
#
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		site_cnt[$1] = $2;
#	} else if (FILENAME == ARGV[2]) {
#		site_type[$1] = $2;	
#		site_cnt_pass[$1] = $3;
#	}
#
#} END {
#	for (site in site_cnt) {
#		print site "\t" site_cnt[site] "\t" site_type[site] "\t" site_cnt_pass[site]; 
#	}
#}' $site_cnt_out $site_type_out > ${out}

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		site_cnt[$1] = $2;
		site_type[$1] = $3;
		site_pass_cnt[$1] = $4;
	} else if (FILENAME == ARGV[2]) {
		for (site in site_cnt) {
			if (index($2, site)) {
				site_no_tag_cnt[site]++;
				break;
			}
		}
	} else if (FILENAME == ARGV[3]) {
		for (site in site_cnt) {
			if (index($2, site)) {
				site_no_type_cnt[site]++;
				break;
			}
		}
	} else if (FILENAME == ARGV[4]) {
		for (site in site_cnt) {
			if (index($2, site)) {
				site_conflict_cnt[site]++;
				break;
			}
		}
	}
} END {
	for (site in site_cnt) {
		print site "\t" site_cnt[site] "\t" site_type[site] "\t" site_pass_cnt[site] "\t" site_no_tag_cnt[site] "\t" site_no_type_cnt[site] "\t" site_conflict_cnt[site];
	}

}' ${out} ${no_tag} ${no_type} ${conflict} > ${out_with_no_tag}
