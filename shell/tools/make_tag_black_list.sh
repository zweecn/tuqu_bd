#!/bin/bash

black="conf/tag_black_list"
mine_white="conf/mine_pm_pass"
dingxiang_white="conf/dingxiang_pm_pass"
pm_pass_new="conf/pm_pass_new"
out="conf/tag_black_list.out"

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		mine_pm_pass[$1] = $2;
	} else if (FILENAME == ARGV[2]){
		dingxiang_pm_pass[$1] = $2;
	} else if (FILENAME == ARGV[3]){
		pm_pass_tag_new[$1] = 1;	
	} else {
		if ($1 in mine_pm_pass || $1 in dingxiang_pm_pass || $1 in pm_pass_tag_new) {
			next;
		} else {
			print tolower($1);
		}
	}

}' ${mine_white} ${dingxiang_white} ${pm_pass_new} ${black} | sort | uniq > ${out}
