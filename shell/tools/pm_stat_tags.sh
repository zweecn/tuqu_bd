#!/bin/bash

awk -F '\t' '{
	if (!mark[$1]) {
		print;
		mark[$1] = 1;
	}

}' data/swap/dingxiang_final_objs_data data/swap/mine_final_objs_data ../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data ../tuqu_baidu_other4/data/swap/mine_final_objs_data > data/temp/all_final

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		tags[$1] = 0;	
	} else {
		split($2, arr, ",");	
		for (i in arr) {
			if (arr[i] in tags) {
				tag_cnt[arr[i]] ++;
			}
		}
	}

} END {
	for (tag in tag_cnt) {
		print tag "\t" tag_cnt[tag];
	}
}' conf/pm_tags data/temp/all_final > data/temp/pm_tag_cnt

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		tag_cnt[$1] = $2;
	} else {
		print $1 "\t" tag_cnt[$1];
	}
}' data/temp/pm_tag_cnt conf/pm_tags > data/temp/pm_tag_cnt.txt
