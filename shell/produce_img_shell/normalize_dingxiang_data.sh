#!/bin/bash
### usage 把数据格式化为统一的字段序列

#############################################################################
# 数据文件
#
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"

# 输入输出文件
objs_dingxiang=${input}"/objs_all";
output=${swap}"/dingxiang_data_normalized";

#############################################################################
# 代码开始
#

awk -F '\t' '{
    # objURL    fromURL     tags
    if (!mark[$8]) {
		print $8"\t"$9"\t"$13;
		mark[$8] = 1;
	}
}' ${objs_dingxiang} > ${output}

if [ ${?} -ne 0 ]
then 
    echo "归一化定向（合作）数据失败!";
    exit 1;
fi;
