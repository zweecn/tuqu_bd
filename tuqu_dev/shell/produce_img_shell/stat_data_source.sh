#!/bin/bash

#input="data/data_source";
used_objs="data/used_objs";
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
        print type"\t"count[type];
        total+=count[type];
    }
    print "total="total;
}' ${used_objs} ${input}
