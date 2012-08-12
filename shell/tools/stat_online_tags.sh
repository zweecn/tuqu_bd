#!/bin/bash

online_objs="data/input/used_objs"
type2_tag="conf/type2_tag"
final_objs="bak/final_objs_data"

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		type2_tag[$1] = 0;
	} else if (FILENAME == ARGV[2]){
		split($2, tags, ",");
		used[$1] = 1;
		for (i in tags) {
			tag = tags[i];
			if (tag != "" && tag in type2_tag) {
				type2_tag[tag]++;
			}
		}
	} else {
		if ($1 in used) {
			next;
		} else {
			split($2, tags, ",");
			tag = tags[i];
			if (tag in type2_tag) {
				type2_left[tag]++;
			}
		}
	}
} END {
	print "tag	已经上线	还剩下"
	for (tag in type2_tag) {
		print tag"\t"type2_tag[tag]"\t"type2_left[tag];
	}
}' ${type2_tag} ${online_objs} ${final_objs}
