#!/bin/bash

#prefix="dingxiang"
prefix="mine"

echo "统计 " ${prefix} " 的tag在不同文件中的分布..."

filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}.${prefix}
input="./data/input"
swap="./data/swap"
output="./data/output"
today=`date +%Y%m%d`

objs_all="data/input/objs_all"
clean_tag="data/temp/pre_online."${prefix}".clean_tag"
tag_type="data/temp/pre_online.${prefix}.tag_type"
filter_tags="data/temp/pre_online."${prefix}".tag_type.filter_tags"
dingxiang_without_path="data/swap/"${prefix}"_final_objs_data.without_path"
dingxiang_with_path="data/swap/"${prefix}"_final_objs_data"
used_objs="data/input/used_objs"
out=${temp}".stat"

dingxiang_tag_list="conf/dingxiang_pm_tag_count"
mine_tag_list="conf/mine_pm_tag_count"

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		pm_dingxiang[$1] = $2;	
		tag_cnt[$1] = 0;
		tag_clean_tag[$1] = 0;
		tag_tag_type[$1] = 0;
		tag_filter_tags[$1] = 0;
		tag_without_path[$1] = 0;
	} else if (FILENAME == ARGV[2]){
		tag_line = $13;
		gsub("\\ ", "-", tag_line);
		gsub(",", "$$", tag_line);
		delete tags;
		split(tag_line, tags, "\\$\\$");
		for (i in tags) {
			if (tags[i] in pm_dingxiang) {
				tag_cnt[tags[i]]++;
			}
		}
	} else if (FILENAME == ARGV[3]) {
		delete tags;
		split($3, tags, ",");
		for (i in tags) {
			if (tags[i] in pm_dingxiang) {
				tag_clean_tag[tags[i]]++;
			}
		}
	} else if (FILENAME == ARGV[4]) {
		delete tags;
		split($3, tags, ",");
		for (i in tags) {
			if (tags[i] in pm_dingxiang) {
				tag_tag_type[tags[i]]++;
			}
		}

	} else if (FILENAME == ARGV[5]) {
		delete tags;
		split($3, tags, ",");
		for (i in tags) {
			if (tags[i] in pm_dingxiang) {
				tag_filter_tags[tags[i]]++;
			}
		}
	} else if (FILENAME == ARGV[6]){
		delete tags;
		split($3, tags, ",");
		for (i in tags) {
			if (tags[i] in pm_dingxiang) {
				tag_without_path[tags[i]]++;
			}
		}
	} else if (FILENAME == ARGV[7]) {
		used[$1] = 1;	
	} else {
		delete tags;
		split($2, tags, ",");
		for (i in tags) {
			if (tags[i] in pm_dingxiang) {
				tag_with_path[tags[i]]++;
				
				if (!($1 in used)) {
					tag_useful[tags[i]]++;
				}
			}
		}
		
	}
} END {
	print "Tag \t PM \t clean \t tag_type \t filter \t no_path \t path \t useful";
	for (i in tag_cnt) {
		print i "\t" pm_dingxiang[i] "\t" tag_clean_tag[i] "\t" tag_tag_type[i]  "\t" tag_filter_tags[i] "\t" tag_without_path[i] "\t" tag_with_path[i] "\t" tag_useful[i];

	}

}' ${dingxiang_tag_list} ${objs_all} ${clean_tag} ${tag_type} ${filter_tags} ${dingxiang_without_path} ${used_objs} ${dingxiang_with_path} > ${out}

echo "统计完成." ${out}
