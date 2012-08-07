#!/bin/bash

####################################################################################
#	基本数据目录
# 	filename 		程序正在执行的脚本文件名
# 	temp			程序中间生成的临时文件目录
#	input			主程序的原始输入目录，手工提供的数据
#	swap			本脚本或者其他脚本的输入/输出文件目录，供脚本之间传递输入输出
#	output			主程序的输出文件
#	today			今天的日期，格式是类似于 "20120802"

filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
today=`date +%Y%m%d`
###################################################################################

final_objs=${swap}"/merge_final_objs_data"
need="conf/img.need"
used_obj=${input}"/used_objs"
out=${swap}"/other_4_base_data"
lack=${temp}".lack"

echo -e "开始选择数据..."

awk -F '\t' -v lack="${lack}.tmp" '{
	if (FILENAME == ARGV[1]) {
		need[$1] = 200;
	} else if (FILENAME == ARGV[2]){
		used[$1] = 1; 
	} else {
		split($2, tags, ",");
		for (i in tags) {
			if (tags[i] in need && need[tags[i]] > 0) {
				need[tags[i]]--;
				print $1"\t"$2"\t"$3"\t"$4;
			}
		}
	}
} END {
	for (i in need) {
		if (need[i] > 0) {
			print i"\t"need[i] > lack;
		}
	}
}' ${need} ${used_obj} ${final_objs} > ${out}.with_used

awk -F '\t' -v online="${out}.online" '{
	if (FILENAME == ARGV[1]){
		used[$1] = 1; 
	} else {
		if ($1 in used) {
			print > online;
			next;
		}
		print $0;
	}
}' ${used_obj} ${out}.with_used | awk -F '\t' '{
    print $0"\t"rand();
}' | sort -n -k5 | awk -F'\t' '{
    print $1"\t"$2"\t"$3"\t"$4;
}' > ${out}

sort -n -r -k2 ${lack}.tmp > ${lack}
rm ${lack}.tmp

echo -e "总共生成数据输出为 ${out}.with_used `wc -l ${out}.with_used | cut -d ' ' -f 1` 行"
echo -e "其中已经在线上图片有 ${out}.online `wc -l ${out}.online | cut -d' ' -f 1` 行"
echo -e "还需要灌库的数据输出为 ${out} `wc -l ${out} | cut -d ' ' -f 1` 行"
echo -e "还缺少的数据输出为 ${lack}"
