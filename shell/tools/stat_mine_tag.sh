#!/bin/bash

echo "统计挖掘数据的tag在不同文件中的分布..."

filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}".mine"
input="./data/input"
swap="./data/swap"
output="./data/output"
today=`date +%Y%m%d`

merged="data/mine_data/merged"
source_valid="data/mine_data/source_valid"
source_valid_rm_useless="data/mine_data/source_valid.rm_useless"
sus_out="data/mine_data/output"
thumb=${input}"/output.thumb"
out=${swap}"mine_stat"

mine_tag_list="conf/mine_pm_tag_count"

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		pm_mine[$1] = $2;	
		tag_merged[$1] = 0;
	} else if (FILENAME == ARGV[2]){
		tag_line = $26;
		gsub("\\ ", "_", tag_line);
		gsub(",", "$$", tag_line);
		tag_line = tolower(tag_line); 
		delete tags;
		split(tag_line, tags, "\\$\\$");
		for (i in tags) {
			if (tags[i] in pm_mine) {
				tag_merged[tags[i]]++;
			}
		}
	} else if (FILENAME == ARGV[3]){
		tag_line = $NF;
		gsub("\\ ", "_", tag_line);
		gsub(",", "$$", tag_line);
		tag_line = tolower(tag_line); 
		delete tags;
		split(tag_line, tags, "\\$\\$");
		for (i in tags) {
			if (tags[i] in pm_mine) {
				tag_valid[tags[i]]++;
			}
		}
	} else if (FILENAME == ARGV[4]){
		tag_line = $3;
		gsub("\\ ", "_", tag_line);
		gsub(",", "$$", tag_line);
		tag_line = tolower(tag_line); 
		delete tags;
		split(tag_line, tags, "\\$\\$");
		for (i in tags) {
			if (tags[i] in pm_mine) {
				tag_valid_rm[tags[i]]++;
			}
		}
	} else if (FILENAME == ARGV[5]){
		tag_line = $4;
		gsub("\\ ", "_", tag_line);
		gsub(",", "$$", tag_line);
		tag_line = tolower(tag_line); 
		delete tags;
		split(tag_line, tags, "\\$\\$");
		for (i in tags) {
			if (tags[i] in pm_mine) {
				sus_out[tags[i]]++;
			}
		}
	} else {
		tag_line = $3;
		gsub("\\ ", "_", tag_line);
		gsub(",", "$$", tag_line);
		tag_line = tolower(tag_line); 
		delete tags;
		split(tag_line, tags, "\\$\\$");
		for (i in tags) {
			if (tags[i] in pm_mine) {
				tag_thumb[tags[i]]++;
			}
		}
	}
} END {
	for (i in pm_mine) {
		print i "\t" pm_mine[i] "\t" tag_merged[i] "\t" tag_valid[i] "\t" tag_valid_rm[i] "\t" sus_out[i] "\t" tag_thumb[i]; 
	}

}' ${mine_tag_list} ${merged} ${source_valid} ${source_valid_rm_useless} ${thumb} > ${out}

echo "统计完成."
