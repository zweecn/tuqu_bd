#!/bin/bash
### usage 把数据格式化为统一的字段序列

#############################################################################
# 数据文件

filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"

objs_mine=${input}"/output.thumb";
input_other=${input}"/gaoxiaoo_idsoo_kaixin001_laifu_taitaitang.out";
output=${swap}"/mining_data_normalized";

#############################################################################
# 代码开始
#
awk -F '\t' '{
    if (FILENAME == ARGV[1]) {
		# objURL    fromURL     tags
		parser_tag=$3;
		mining_tag=$4;
		if(parser_tag!=""){
		tag_str=parser_tag;
		}else{
			tag_str=mining_tag;
		}
    	if (!mark[$2]) {
			print $2"\t"$6"\t"tag_str;
			mark[$2] = 1;
		}
	} else {
		if (!mark[$1]) {
			print $1"\t"$2"\t"$4;
			mark[$1] = 1;
		}
	}
}' ${objs_mine} ${input_other}  > ${output}

if [ ${?} -ne 0 ]
then 
    echo "归一化挖掘数据失败!";
    exit 1;
fi;
