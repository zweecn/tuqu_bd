#!/bin/bash
####################################################################################
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
####################################################################################

####################################################################################
# 输入输出文件
final_objs=${swap}"/final_objs_data";
used_objs=${output}"/used_objs";
used_objs_backup=${output}"/used_objs_backup/used_objs.bak";
out=${output}"/data_for_tuqu/data_index."`date +%Y%m%d`;

####################################################################################
# 配置文件
# 每日PM的需求数据数量
type_demand_amount="conf/type_demand_amount";

echo "开始选择数据..."

### 选择数据
awk -F '\t' -v tmp_used_objs="${temp}.used_objs" -v output="${temp}.candidate" '{
    if(FILENAME==ARGV[1]){
        type_demands[$1]=$2;
        total_needed+=$2;
    }else if(FILENAME==ARGV[2]){
        used[$1]=1;
    }else{
        if($1 in used)
            next;
        if(type_selected[$NF]<type_demands[$NF]){
            print $1"\t"$2"\t"$3"\t"$4 > output;
            print $1"\t"$2 > tmp_used_objs;
            type_selected[$NF]++;
        }
    }
}END{
    for(type in type_selected){
        print type"\t"type_selected[type]"/"type_demands[type];
        count+=type_selected[type];
    }
    if(count!=total_needed){
        print "生成数据失败！请检查配置文件和可用数据量是否过少.";
        exit 1;
    }
    for(type in type_selected){
        if(type_selected[type]<type_demands[type]){
            print "类型数据过少! 生成data_index失败！！！";
            exit 1;
        }
    }
}' ${type_demand_amount} ${used_objs} ${final_objs};
if [ ${?} -ne 0 ]
then
    echo "生成数据"${out}"失败!";
    exit 1;
fi;

### 随机打散obj，使得obj在文件中的数据平均分布
awk -F '\t' '{
    print $1"\t"$2"\t"$3"\t"$4"\t"rand();
}' ${temp}.candidate | sort -t '	' -n -k5,5 | cut -f1,2,3,4 > ${out};
if [ ${?} -ne 0 ]
then
    echo "随机打散类型obj失败!";
    exit 1;
fi;
cat ${temp}.used_objs >> ${used_objs};
if [ ${?} -ne 0 ]
then
    echo "合并使用过的obj失败！";
    exit 1;
fi;

cp ${used_objs} ${used_objs_backup}.after.`date +%Y%m%d`
if [ ${?} -ne 0 ]
then
    echo -e "备份${used_objs}失败!"
	exit 1;
fi;

echo -e "选择数据完成，输出文件为 ${out}"
