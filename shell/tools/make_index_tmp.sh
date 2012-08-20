#!/bin/bash

log="log/uploadFromFile.sh.log.20120817"
used="data/temp/log_used"
mine="data/swap/mine_final_objs_data"
dingxiang="data/swap/dingxiang_final_objs_data"
index="data/output/data_for_tuqu/data_index.20120817"
index_out="data/output/data_for_tuqu/data_index.20120817.out"

#perl -lne '{
#	if ($_ =~ /file=@(.*?\.html)/) {
#		print $1;
#	}
#}' ${log} > ${used}


awk -F'\t' '{
	if (FILENAME == ARGV[1]) {
		used[$1] = 1;
	} else if (FILENAME == ARGV[2]) {
		if ($4 in used)
			next;
		need[$1] = 1;
	} else if (FILENAME == ARGV[3] || FILENAME == ARGV[4]) {
		if ($1 in need) {
			print $1"\t"$2"\t"$3"\t"$4;			
		}
	}
}' ${used} ${index} ${mine} ${dingxiang} > ${index_out}
