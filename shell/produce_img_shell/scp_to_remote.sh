#!/bin/bash
######################################################################################
#	基本数据目录
# 	filename 		程序正在执行的脚本文件名
# 	temp			程序中间生成的临时文件目录
#	input			主程序的原始输入目录，手工提供的数据
#	swap			本脚本或者其他脚本的输入/输出文件目录，供脚本之间传递输入输出
#	output			主程序的输出文件
#	today			今天的日期，格式是类似于 "20120802"
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}.${prefix}
input="./data/input"
swap="./data/swap/"${prefix}
output="./data/output"
today=`date +%Y%m%d`
####################################################################################

# 输入文件  需要拷贝的数据
index_dingxiang=${output}"/data_for_tuqu/data_index.dingxiang."${today}
index_mine=${output}"/data_for_tuqu/data_index.mine."${today}

# 远程机器的配置文件
remote_server=`cat conf/remote_server`
# 需要拷贝到数据文件名

filename_dingxiang=`echo ${index_dingxiang} | awk -F'[./]' '{ print $(NF - 1)}'`
filename_mine=`echo ${index_mine} | awk -F'[./]' '{ print $(NF - 1)}'`

echo -e "开始拷贝至远程主机: ${remote_server}"

scp ${index_dingxiang} ${remote_server}
if [ ${?} -ne 0 ]
then
    echo "拷贝数据至远程机器失败!"
    exit 1
fi
echo -e "拷贝至远程主机成功，文件为 ${remote_server}/${filename_dingxiang}"

scp ${index_mine} ${remote_server}
if [ ${?} -ne 0 ]
then
    echo "拷贝数据至远程机器失败!"
    exit 1
fi
echo -e "拷贝至远程主机成功，文件为 ${remote_server}/${filename_mine}"

