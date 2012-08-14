#!/bin/bash

data="v2/data/swap/final_objs_data"

awk -F '\t' '{
	if ($NF == "вш╨о")
		next;
	split($2, tags, ",");
	cnt = 0;
	for (i in tags) {
		cnt++;
	}

	if (cnt < 2)
		print;
}' ${data} 
