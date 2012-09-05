#!/bin/bash

# 从这里开始统计
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		black_objs[$1] = 1;
	} else {
		if (!mark[$1] && !($1 in black_objs))  {
			print;
			mark[$1] = 1;
		}
	}
}' conf/obj_black_list data/temp/pre_online.mine.tag_type data/temp/pre_online.mine.type_conflict ../tuqu_baidu_other4/data/temp/pre_online.mine.tag_type ../tuqu_baidu_other4/data/temp/pre_online.mine.type_conflict > data/temp/all_with_conflict

# 统计是否下载
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		objs_path[$2] = $1;
	} else {
		if ($1 in objs_path) {
			print > "data/temp/all_downloaded";
		} else {
			print > "data/temp/all_no_downloaded";
		}
	}
}' data/input/objs_local_path data/temp/all_with_conflict

awk -F '\t' '{
	split($3, arr, ",");	
	for (i in arr) {
		tag_cnt[arr[i]] ++;
	}
} END {
	for (tag in tag_cnt) {
		print tag "\t" tag_cnt[tag];
	}
}' data/temp/all_with_conflict | sort -n -k2 -r > data/temp/all_tag_cnt.without_add_type.txt

# 以下统计增加的标签数量, 大类被增加为tag
d1="data/swap/dingxiang_final_objs_data.without_path"
d2="data/swap/mine_final_objs_data.without_path"
d3="../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data.without_path" 
d4="../tuqu_baidu_other4/data/swap/mine_final_objs_data.without_path"
awk -F '\t' '{
	if (FILENAME == ARGV[1] || FILENAME == ARGV[3]) {
		split($NF, arr, "-");
		if (arr[2] != "" && !mark[$1]) { 
			print $1 "\t" arr[2];
			mark[$1] = 1;
		}
	} else {
		if ($NF != "" && !mark[$1]) {
			print $1 "\t" $NF;
			mark[$1] = 1;
		}
	}
}' $d1 $d2 $d3 $d4 | sort -k2 > data/temp/all_final_without_path 

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		add_tag[$1] = $2;
	} else {
		split($3, arr, ",");
		add = 1;
		for (i in arr) {
			tag_cnt[arr[i]] ++;
			if (arr[i] == add_tag[$1]) {
				add = 0;
			}
		}
		if (add && add_tag[$1] != "") {
			tag_cnt[add_tag[$1]]++;
		}
	}
} END {
	for (tag in tag_cnt) {
		print tag "\t" tag_cnt[tag];
	}
}' data/temp/all_final_without_path data/temp/all_with_conflict | sort -n -k2 -r > data/temp/all_tag_cnt.txt

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		tags[$1] = 1;	
	} else {
		if (!($1 in tags)) {
			print;
		}
	}
}' conf/tag_black_list data/temp/all_tag_cnt.txt > data/temp/all_tag_cnt_without_black_tag.txt

cp conf/pm_tags data/temp/pm_tags
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		tags[$1] = 0;
	} else if (FILENAME == ARGV[2]) {
		tags[$1] = $2;
	} else {
		if ($1 in tags) {
			print $1 "\t" tags[$1];
		}
	}
}' conf/pm_tags data/temp/all_tag_cnt_without_black_tag.txt data/temp/pm_tags > data/temp/pm_tag_cnt.txt

