#!/bin/bash

awk -F '\t' '{
	split($2, tags, ",");
	for (i in tags) {
		if (tags[i] == "ŷ����")
		print;
	}
}' data/swap/mine_final_objs_data 
