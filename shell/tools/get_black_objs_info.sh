#!/bin/bash

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		objs[$1] = 1;
	} else {
		if ($1 in objs) {
			print;
		}
	}

}' conf/obj_black_list data/swap/mine_data_normalized data/swap/dingxiang_data_normalized > data/temp/black_objs_info
