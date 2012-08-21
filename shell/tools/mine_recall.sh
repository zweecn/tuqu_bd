#!/bin/bash

q_tags="conf/q_tags"
no_pass="data/bad_tag_data/no_pass"
releated_tags="data/bad_tag_data/rel"

while read tag
do
	path="data/bad_tag_data/pinggu/$tag"
	res=`ls $path`
	if [ $? -ne 0 ]; then 
		continue;
	fi
	awk -F '\t' '{
		delete tags;
		split($NF, tags, ",");
		for (i in tags) {
			tag = tags[i];
			cnt[tag]++;
		}
	} END {
		for (tag in cnt) {
			print tag "\t" cnt[tag];
		}
	}' $path  | sort -k2 -n -r > ${releated_tags}/$tag
done < $q_tags

pass_tag_dir="data/bad_tag_data/pass_tag/"
pinggu_dir="data/bad_tag_data/pinggu/"
pass_tag=`ls $pass_tag_dir`
no_pass_tag="data/bad_tag_data/no_pass_tag"
out="data/bad_tag_data/recall_out"
out_rand="data/bad_tag_data/recall_out.rand"

rm -rf $no_pass_tag
rm -rf ${out}
for tag in ${pass_tag[@]}
do
	echo $tag >> ${no_pass_tag}; 
	pinggu_file="${pinggu_dir}$tag"
	tag_file="${pass_tag_dir}$tag"
	echo $pinggu_file
	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			pass_tag[$1] = 1;
		} else {
			split($NF, tags, ",");
			tag_str = "";
			for (i in tags) {
				tag = tags[i];
				if (tag in pass_tag) {
					if (tag_str == "") {
						tag_str = tag;
					} else {
						tag_str = tag_str "," tag;
					}
				} else {
					tag_str = "";
					break;	
				}
			}
			if (tag_str != "") 
				print $1 "\t" $2 "\t" tag_str;
		}
	}' ${tag_file} $pinggu_file >> ${out}.tmp
done

sort ${out}.tmp | uniq > ${out}

awk -F '\t' '{
	print $0 "\t" rand();
}' ${out} | sort -n -k4 | head -n 100 | cut -f1,2,3 | sort | uniq | sort -k3  > ${out_rand}
