#!/bin/bash

f1="data/to_pm/4_type_mine_tag_freq.txt"
f2="data/to_pm/5_type_dingxiang_tag_freq.txt"
out="data/to_pm/all_tag_freq.txt"

awk -F '\t' '{
	freq[$1] += $2;
} END {
	for (tag in freq) {
		print tag "\t" freq[tag];
	}
}' ${f1} ${f2} | sort -n -r -k2 > ${out}

echo "Finished"
