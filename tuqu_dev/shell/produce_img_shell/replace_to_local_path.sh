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
out=${input}"/objs_local_data"
remote_host="img@jx-apptest-img04.vm.baidu.com"
remote_path="/home/img/shiym/dingxiang/work/client/"
local_path=`pwd`"/data/"
today=`date +%Y%m%d`

#sed -e 's/\/home\/img\/shiym\/dingxiang\/work\/client/data/g' ${input} > ${output}

# 替换时可以批量转换，用另外的字符#作为分隔符/
sed -e "s#${remote_path}#${local_path}#g"  ${in} > ${out}

if [ $? -ne 0 ]
then
	echo 'Replace path to local path failed.'
	exit 1
fi

mv ${in} ${in}.bak.${today}
cp ${out} ${in}

