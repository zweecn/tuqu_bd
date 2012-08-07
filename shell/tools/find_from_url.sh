#!/bin/bash

file="data/swap/mine_final_objs_data.without_path"

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		a[$1] = 1;
		print $1;
	} else {
		if ($1 in a) {
			print $0;
		}
	}

}' obj ${file} 
