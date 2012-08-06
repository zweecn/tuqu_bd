#!/bin/bash
###################################################################################
#	基本数据目录
# 	filename 		程序正在执行的脚本文件名
# 	temp			程序中间生成的临时文件目录
#	input			主程序的原始输入目录，手工提供的数据
#	swap			本脚本或者其他脚本的输入/输出文件目录，供脚本之间传递输入输出
#	output			主程序的输出文件
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
###################################################################################

in=${input}"/objs_local_path"
out=${temp}".objs_local_path"
base_path=`pwd`"/data/res"


awk -F 'res' -v base="${base_path}" '{
	print base$2; 
}' ${in} > ${out}

cp ${out} ${in}
