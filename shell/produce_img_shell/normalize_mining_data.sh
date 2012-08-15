#!/bin/bash
###################################################################################
#
#	脚本功能: 
#		挖掘数据的格式比较混乱，部分内容不需要。
#		因此将定向数据格式化为我们需要的数据格式。
#	输入的数据格式为:
#		1. ${objs_mine}的字段说明
#			以\t分割，第2字段为obj_url，第6字段为from_url，第3字段为原始图片的tag
#			第4字段为挖掘的tag
#		2. ${input_other}的字段说明
#			obj_url \t from_url \t title \t tags
#	格式化后的数据格式为:
#		obj_url \t from_url	\t tags
#
###################################################################################
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

# 输入输出文件
objs_mine=${input}"/output.thumb";
input_other=${input}"/gaoxiaoo_idsoo_kaixin001_laifu_taitaitang.out";
out=${swap}"/mine_data_normalized";

###################################################################################
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
}' ${objs_mine} ${input_other}  > ${out}

if [ ${?} -ne 0 ]
then 
    echo "[错误]	归一化挖掘数据失败!";
    exit 1;
fi;

echo -e "[输出]	格式化挖掘数据完成. 输出文件为 ${out}"
