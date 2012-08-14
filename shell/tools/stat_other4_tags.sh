#!/bin/bash

d="data/other_4/other_4_base_data"

pm="conf/img.need"

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		pm[$1] = 0;
	} else {
		delete tags;
		split($2, tags, ",");
		for (i in tags) {
			tag = tags[i];
			if (tag in pm) 
				cnt[tag]++;
		}
	}
} END {
	for (tag in pm) {
		if (cnt[tag] < 200)
			print tag"\t"cnt[tag];
	}

}' ${pm} ${d}
