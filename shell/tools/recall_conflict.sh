#!/bin/bash

dingxiang="data/temp/pre_online.dingxiang.type_conflict"
dingxiang_out="data/temp/pre_online.dingxiang.type_conflict.rand100"
dingxiang_tag="conf/dingxiang_tag_list"

#awk -F '\t' '{
#	print $0"\t"rand(); 
#}' ${dingxiang} | sort -n -k6 | awk -F '\t' '{
#	print $1"\t"$2"\t"$3"\t"$4"\t"$5;
#}' | head -n 100 > ${dingxiang_out}

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		pm_types[$1] = $2;	
	} else {
		if ($NF == 0) {
			if (!mark[$1]) {
				print;
				mark[$1] = 1;
			}
			next;
		}
		split($3, tags, ",");
		delete img_type;
		type_cnt = 0;
		for (i in tags) {
			tag = tags[i];
			if (tag in pm_types) {
				img_type[tag] = 1;	
				type_cnt++;
			}
			if (tag in pm_types && pm_types[tag] == 0) {
				if (!mark[$1]) {
					print;	
					mark[$1] = 1;
				}
			}
		}
		
	}
}' ${dingxiang_tag} ${dingxiang} > ${dingxiang}.0

awk -F'\t' '{
	if (FILENAME == ARGV[1]) {
		pm_types[$1] = $2;	
	} else {
		split($3, tags, ",");
		delete img_type;
		type_cnt = 0;
		for (i in tags) {
			tag = tags[i];
			if (tag in pm_types) {
				img_type[tag] = 1;	
				type_cnt++;
			}
		}
		if (type_cnt == 2)
			print;
	}
}' ${dingxiang_tag} ${dingxiang}.0 > ${dingxiang}.0.2type

echo "Íê³É."

