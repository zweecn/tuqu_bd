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

dx_final_objs=${swap}"/dingxiang_final_objs_data"
mi_final_objs=${swap}"/mine_final_objs_data"
need="conf/img.need"
used_obj=${output}"/used_objs"
out=${swap}"/merge_final_objs_data"

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		split($6, arr, "-");
		if (!mark[1]) {
			print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"arr[2];
			mark[$1] = 1;
		}
	} else if (FILENAME == ARGV[2]) {
		if (!mark[1]) {
			print;
			mark[$1] = 1;
		}
	}

}' ${dx_final_objs} ${mi_final_objs} > ${out}
