#!/bin/bash


function stat_tags_final_objs
{
	tag_modify=$1
	pm_tags=$2
	final_objs_data_without_path=$3
	final_objs_data=$4
	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			tag_modi_reverse[$2] = $1;
			tag_modi[$1] = $2;
		} else if (FILENAME == ARGV[2]) {
			pm_tag_cnt[$1] = $2;	
			last_tag_cnt_no_path[$1] = 0;
			last_tag_cnt[$1] = 0;
		} else if (FILENAME == ARGV[3]) {
			split($3, tags, ",");		
			for (i in tags) {
				tag = tags[i];
				if (tag == "服饰") {
					print;
				}
				if (tag in pm_tag_cnt) {
					last_tag_cnt_no_path[tag]++;
				} else if (tag in tag_modi_reverse) {
					last_tag_cnt_no_path[tag_modi_reverse[tag]]++;
				}
			}
		} else if (FILENAME == ARGV[4]) {
			split($2, tags, ",");		
			for (i in tags) {
				tag = tags[i];
				if (tag in pm_tag_cnt) {
					last_tag_cnt[tag]++;	
				} else if (tag in tag_modi_reverse) {
					last_tag_cnt[tag_modi_reverse[tag]]++;
				}

			}
		}
	
	} END {
		print "tag \t PM统计值 \t 包括没下载的	完全下载的	标签修改" ;
		for (tag in pm_tag_cnt) {
			print tag "\t" pm_tag_cnt[tag] "\t" last_tag_cnt_no_path[tag] "\t" last_tag_cnt[tag] "\t" (tag in tag_modi ? tag_modi[tag] : ""); 
		}
	
	}' ${tag_modify} ${pm_tags} ${final_objs_data_without_path} ${final_objs_data} 
} 

stat_tags_final_objs "conf/dingxiang_tag_modified" "conf/dingxiang_pm_tag_count" "data/swap/dingxiang_final_objs_data.without_path" "data/swap/dingxiang_final_objs_data" > ${temp}.final_tag_stat

function merge_tags_stat
{
	tag_modify=$1
	stat_tag=$2
	final_tag=$3
	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			tag_modi[$1] = $2;
		} else if (FILENAME == ARGV[2]) {
			pm_tag_cnt[$1] = $2;	
			total_tag_cnt[$1] = $3;
			conflict_tag_cnt[$1] = $4;
			no_tag_cnt[$1] = $5;
			tag_left_cnt[$1] = $6;
		} else if (FILENAME == ARGV[3]) {
			last_tag_cnt_no_path[$1] = $3;
			last_tag_cnt[$1] = $4;
		}
	} END {
		for (tag in pm_tag_cnt) {
			print tag "\t" pm_tag_cnt[tag] "\t" total_tag_cnt[tag] "\t" conflict_tag_cnt[tag] "\t" no_tag_cnt[tag] "\t" tag_left_cnt[tag] "\t" last_tag_cnt_no_path[tag] "\t" last_tag_cnt[tag] "\t" (tag in tag_modi ? tag_modi[tag] : ""); 
		}
	}' ${tag_modify}  ${stat_tag} ${final_tag}
}

merge_tags_stat "conf/dingxiang_tag_modified" "data/temp/pre_online.dingxiang.stat_tag" ${temp}.final_tag_stat

