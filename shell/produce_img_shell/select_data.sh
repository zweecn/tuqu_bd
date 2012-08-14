#!/bin/bash
function check_file_exist
{
	echo "[检查]	检查文件是否存在..."

	local temp="./data/temp/"
	if [ ! -d ${temp} ]; then
		echo -e "${temp} dir does not exist"
		exit 1
	fi
	
	local input="./data/input/"
	if [ ! -d ${input} ]; then
		echo -e "${input} dir does not exist "
		exit 1
	fi
	
	local swap="./data/swap/"	
	if [ ! -d ${swap} ]; then
		echo -e "${swap} dir does not exist "
		exit 1
	fi
	
	local output="./data/output"
	if [ ! -d ${output} ]; then
		echo -e "${output} dir does not exist"
		exit 1
	fi
	
	local backup_dir="data/input/used_objs_backup"
	if [ ! -d ${backup_dir} ]; then
		echo -e "${backup_dir} dir does not exist"
		exit 1
	fi

	local out=${output}"/data_for_tuqu/"
	if [ ! -d ${out} ]; then
		echo -e "${out} dir does not exist"
		exit 1
	fi

	local dingxiang_final_objs=${swap}"dingxiang_final_objs_data"
	if [ ! -f ${dingxiang_final_objs} ]; then
		echo -e "${dingxiang_final_objs} file does not exist"
		exit 1
	fi

	local mine_final_objs=${swap}"mine_final_objs_data"
	if [ ! -f ${mine_final_objs} ]; then
		echo -e "${mine_final_objs} file does not exist"
		exit 1
	fi

	local used_objs=${input}"/used_objs"	
	if [ ! -f ${used_objs} ]; then
		echo -e "${used_objs} file does not exist"
		exit 1
	fi
		
	echo "[结束]	输入文件检查完毕."
}

function select_data
{
	if [ $# -ne 1 ];then
		echo "[参数]	参数个数错误，正确的参数个数是1."
		exit 1
	fi
	local prefix=$1
	if [ $prefix != "dingxiang" -a $prefix != "mine" ]; then
		echo "[参数]	参数错误. 正确的参数只能是1个: dingxiang 或者 mine ."
		exit 1
	fi

####################################################################################
#	基本数据目录
# 	filename 		程序正在执行的脚本文件名
# 	temp			程序中间生成的临时文件目录
#	input			主程序的原始输入目录，手工提供的数据
#	swap			本脚本或者其他脚本的输入/输出文件目录，供脚本之间传递输入输出
#	output			主程序的输出文件
#	today			今天的日期，格式是类似于 "20120802"
	local filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
	local temp="./data/temp/"${filename}.${prefix}
	local input="./data/input"
	local swap="./data/swap/"${prefix}
	local output="./data/output"
	local today=`date +%Y%m%d`
####################################################################################

####################################################################################
# 输入输出文件
	local final_objs=${swap}"_final_objs_data"
	local used_objs=${input}"/used_objs"
	local used_objs_backup=${input}"/used_objs_backup/used_objs.${prefix}.after."${today}
	local out=${output}"/data_for_tuqu/data_index."${prefix}.${today}

####################################################################################
# 配置文件
# 每日PM的需求数据数量 
	local type_demand_amount="conf/"${prefix}"_type_demand"
	local total_type_demand="conf/total_type_demand"
# 需求中定向和挖掘的需求比例
	local dx_vs_mine="conf/dingxiang_vs_mine"

		
	echo -e "[开始]	开始选择数据 ${prefix}..."
### 选择数据
	awk -F '\t' -v tmp_used_objs="${temp}.used_objs" -v output="${temp}.candidate" ' BEGIN{
		delete type_demands;
	}{
		if(FILENAME==ARGV[1]){
			type_demands[$1]=$2;
			total_needed+=$2;
		}else if(FILENAME==ARGV[2]){
			used[$1]=1;
		}else{
			if($1 in used)
				next;
			if (!($NF in type_demands))
				next;
			if(type_selected[$NF]<type_demands[$NF]){
				print $1"\t"$2"\t"$3"\t"$4 > output;
				print $1"\t"$2 > tmp_used_objs;
				type_selected[$NF]++;
			}
		}
	}END{
		print "\t选择的数据情况:"
		print "\t-------------------------------------------------";
		for(type in type_demands){
			print "\t"type"\t"type_selected[type]"/"type_demands[type];
			count+=type_selected[type];
		}
		print "\t因比例产生的小数舍入会产生误差，实际产生数据 " count " 条.";
		print "\t-------------------------------------------------";
		if(count!=total_needed){
			print "生成数据失败！请检查配置文件和可用数据量是否过少. Need:" total_needed ", Generate:" count;
			exit 1;
		}
		for(type in type_selected){
			if(type_selected[type]<type_demands[type]){
				print "类型数据过少! 生成data_index失败." type " need:" type_demands[type] ", Generate:" type_selected[type];
				exit 1;
			}
		}
	}' ${type_demand_amount} ${used_objs} ${final_objs};
	if [ ${?} -ne 0 ]
	then
		echo -e "[错误]	生成数据 ${temp}.candidate 失败."
		exit 1;
	fi;

### 随机打散obj，使得obj在文件中的数据平均分布
	awk -F '\t' '{
		print $1"\t"$2"\t"$3"\t"$4"\t"rand();
	}' ${temp}.candidate | sort -t '	' -n -k5,5 | cut -f1,2,3,4 > ${out};
	if [ ${?} -ne 0 ]
	then
		echo -e "[错误]	随机打散类型obj失败!";
		exit 1;
	fi;
	cat ${temp}.used_objs >> ${used_objs};
	if [ ${?} -ne 0 ]
	then
		echo -e "[错误]	生成 ${used_objs} 失败!";
		exit 1;
	fi;

	cp ${used_objs} ${used_objs_backup}
#	cp ${temp}.used_objs ${used_objs_backup}
	if [ ${?} -ne 0 ]
	then
		echo -e "[错误]	备份${used_objs}失败!"
		exit 1;
	fi;

	echo -e "[输出]	选择数据完成，输出文件为 ${out}"
}

function merge_dingxiang_mine
{
	echo -e "[开始]	开始合并生成的定向数据和挖掘数据..."
	local today=`date +%Y%m%d`
	local dingxiang="data/output/data_for_tuqu/data_index.dingxiang."${today}
	local mine="data/output/data_for_tuqu/data_index.mine."${today}
	local out="data/output/data_for_tuqu/data_index."${today}
	
	awk -F '\t' '{
		print $1 "\t" $2 "\t" $3 "\t" $4 "\t" rand();
	}' ${dingxiang} ${mine} | sort -k5 -n | cut -d'	' -f 1,2,3,4 > ${out} 

	echo -e "[输出]	生成数据成功. 输出为 ${out}"
}

echo "==============================================================================="
echo -e "[开始时间]	`date` "

# 	1. 检查文件是否存在
check_file_exist
if [ $? -ne 0 ]; then 
	echo "[错误]	缺少配置文件或者输入文件，请检查conf和data目录是否正常."
	exit 1
fi

#	2. 选择定向数据
select_data "dingxiang"
if [ $? -ne 0 ]; then
	echo "[错误]	选择定向数据失败."
fi

#	3. 选择挖掘数据
select_data "mine"
if [ $? -ne 0 ]; then
	echo "[错误]	挖掘数据选择失败."
fi

#	4. 合并定向数据和挖掘数据并打散
merge_dingxiang_mine
if [ $? -ne 0 ]; then
	echo "[错误]	合并定向数据和挖掘数据失败."
fi

echo -e "[结束时间]	`date` "
echo "==============================================================================="
