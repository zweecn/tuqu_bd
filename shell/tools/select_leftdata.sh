#!/bin/bash

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		used[$1] = 1;
	} else {
		if ($1 in used) 
			next;
		if (!mark[$1]) {
			print $1 "\t" $2 "\t" $3 "\t" $4;
			mark[$1] = 1;
		}
	}
}' data/input/used_objs data/swap/dingxiang_final_objs_data data/swap/mine_final_objs_data > data/output/data_for_tuqu/data_index.left
