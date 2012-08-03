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
temp="./data/temp/"${filename}.${prefix}
input="./data/input"
swap="./data/swap/"${prefix}
output="./data/output"
today=`date +%Y%m%d`
####################################################################################

#input="data/data_source";
used_objs=${input}"/used_objs";
if [ $# -ne 1 ]
then
    echo "useage: stat_data_source data_filename";
    exit 1;
fi;
input=$1;
echo ${input};
awk -F '\t' '{
    if(FILENAME==ARGV[1]){
        used_objs[$1]=1;
    }else if(! ($1 in used_objs)){    
        count[$NF]+=1;
    }
}END{
    total=0;
    for(type in count){
        print type"\t|\t"count[type];
        total+=count[type];
    }
    print "total="total;
}' ${used_objs} ${input}
