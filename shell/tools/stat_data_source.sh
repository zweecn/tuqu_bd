#!/bin/bash

####################################################################################
#
#	统计还剩下多少数据
#
####################################################################################
#	input			主程序的原始输入目录，手工提供的数据
input="./data/input"
####################################################################################

used_objs=${input}"/used_objs";
type_index="conf/type_index"

if [ $# -ne 1 ]
then
    echo "useage: stat_data_source data_filename";
    exit 1;
fi;

data=$1;
echo ${data}

awk -F '\t' '{
    if(FILENAME==ARGV[1]){
		count[$1] = 0;
	}
	else if(FILENAME==ARGV[2]){
        used_objs[$1]=1;
    }else if(! ($1 in used_objs)){    
        count[$NF]+=1;
    }
}END{
    total=0;
	for(type in count){
        print type"\t\t"count[type];
        total+=count[type];
    }
    print "total="total;
}' ${type_index} ${used_objs} ${data}

