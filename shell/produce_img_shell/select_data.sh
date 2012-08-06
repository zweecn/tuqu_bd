#!/bin/bash
function restore_used_objs
{
	echo "0. 开始按照前两天的used_objs恢复used_objs..."
	local used_objs="data/input/used_objs"
	local backup_dir="data/input/used_objs_backup"

	local yesterday=`date -d"1 day ago" +"%Y%m%d"`
	local two_days_ago=`date -d"2 day ago" +"%Y%m%d"`
	local three_days_ago=`date -d"3 day ago" +"%Y%m%d"`

	all_used=`ls ${backup_dir}/*${yesterday}*`
	if [ $? -ne 0 ]; then
		echo "昨天的used_objs不存在，尝试前天的."
		all_used=`ls ${backup_dir}/*${two_days_ago}*`
		if [ $? -ne 0 ]; then
			all_used=`ls ${backup_dir}/*${three_days_ago}*`
			if [ $? -ne 0 ]; then
				echo "前天的used_objs不存在，尝试所有的."
				all_used=`ls ${backup_dir}`
				if [ $? -ne 0 ]; then
					echo "没有备份的used_objs，失败!"
					exit 1
				fi
			fi
		fi
	fi

	echo "将从以下文件恢复used_objs:"
	for used in ${all_used[@]}
	do
		echo "	" ${used}
		awk -F '\t' '{
			if (!mark[$1]) {
				print;
				mark[$1] = 1;
			}
		}' ${used} >  ${used_objs}.tmp
	done

	if [ -s ${used_objs}.tmp ]; then
		mv ${used_objs}.tmp ${used_objs}
	fi
	echo "恢复used_objs完成."
}

function stat_data
{
####################################################################################
	local filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
	local temp="./data/temp/"${filename}
	local swap="./data/swap/"
	local input="./data/input"
####################################################################################
	local dingxiang_final_objs=${swap}"dingxiang_final_objs_data"
	local mine_final_objs=${swap}"mine_final_objs_data"
	local used_objs=${input}"/used_objs"	
# 配置文件
# 每日PM的需求数据数量 
	local total_type_demand="conf/total_type_demand"
# 需求中定向和挖掘的需求比例
	local dx_vs_mine="conf/dingxiang_vs_mine"

	local dingxiang_type_demand_amount="conf/dingxiang_type_demand"
	local mine_type_demand_amount="conf/mine_type_demand"
	
#	awk -F '[\t:]' -v xd="${tmp}.dingxiang.need" -v mi="${tmp}.mine.need" '{
#		if (FILENAME==ARGV[1]) {
#			type_demands[$1]=$2;
#			total_needed+=$2;
#		} else if (FILENAME==ARGV[2]) {
#			dx_cnt = total_needed * $1 / ($1+$2);
#			mine_cnt = total_needed - dx_cnt;
#			print dx_cnt"\t"mine_cnt;
#			print dx_cnt > xd;
#			print mine_cnt > mi;
#		}
#
#	}' ${total_type_demand} ${dx_vs_mine} > ${tmp}.demand
	
	echo -e "1. 开始统计数据和按比例生成需要数据..."
	awk -F '[\t]' -v dx_d="${dingxiang_type_demand_amount}" -v mi_d="${mine_type_demand_amount}" -v dx_null_type="${temp}.dingxiang_null_type" -v mi_null_type="${temp}.mine_null_type" '{
		
		if (FILENAME==ARGV[1]) {
			type_demands[$1]=$2;
			total_needed+=$2;
		} else if (FILENAME==ARGV[2]) {
			dx_need = total_needed * $1 / ($1+$2);
			mi_need = total_needed - dx_need;
			print "\t定向数据和挖掘数据分别需要 "dx_need" 和 "mi_need " 张";
		} else if (FILENAME == ARGV[3]) {
			used[$1] = 1;
		} else if (FILENAME == ARGV[4]) {
			if ($1 in used)
				next;
			if ($6 == "") {
				print $0 > dx_null_type;
				next;
			}
			dx_cnt[$6]++;
			dx_total++;
		} else if (FILENAME == ARGV[5]) {
			if ($1 in used)
				next;
			if ($6 == "") {
				print $0 > mi_null_type;
				next;
			}
			mi_cnt[$6]++;
			mi_total++;
		} 	
	} END {
		print "\t定向数据:\tTotal:" dx_total "\tNeed:" dx_need;
		print "\t库中还有点图片数据为:";
		print "\t-------------------------------------------------"
		for (t in dx_cnt) {
#			need_t = dx_need/dx_total*dx_cnt[t];
			need_t = dx_need*dx_cnt[t]/dx_total;
			split(t, arr, "-");
#			if (need_t > type_demands[arr[2]]) {
#				need_t = type_demands[arr[2]];
#			}
#			type \t need_count \t now_left_count
			printf("%s\t%d\t%d\n", t, need_t, dx_cnt[t]) > dx_d;
			printf("\t%s\t%d\n", t, dx_cnt[t]);
			dx_types[arr[2]] += need_t;
		}
		print "\t-------------------------------------------------"
		print "\t挖掘数据:\tTotal:" mi_total "\tNeed:" mi_need;
		print "\t库中还有点图片数据为:";
		print "\t-------------------------------------------------"
		for (t in mi_cnt) {
			need_t = type_demands[t] - dx_types[t];
			if (need_t < 0) {
				need_t = 0;
			}
			printf("%s\t%d\t%d\n", t, need_t, mi_cnt[t]) > mi_d;
			printf("\t%s\t%d\n", t, mi_cnt[t]);
		}
		print "\t-------------------------------------------------"
		if (dx_total < dx_need || mi_total < mi_need) {
			print "\t警告:库中数据量不足，后续无法选择. 定向剩余/定向需求=" dx_total"/"dx_need " 挖掘剩余/挖掘需求=" mi_total"/"mi_need;
		}
	}' ${total_type_demand} ${dx_vs_mine} ${used_objs} ${dingxiang_final_objs} ${mine_final_objs}

	echo -e "	已按照定向数据所占比例生成各大类数据，输出为 ${dingxiang_type_demand_amount}"
	echo -e "	已按照挖掘数据所占比例生成各大类数据，输出为 ${mine_type_demand_amount}"
	echo -e "	发现一堆数据没有大类型，输出为 ${temp}.dingxiang_null_type"
	echo -e "	发现一堆数据没有大类型，输出为 ${temp}.mine_null_type"
}

function select_data
{
	if [ $# -ne 1 ];then
		echo "参数个数错误，正确的参数个数是1."
		exit 1
	fi
	local prefix=$1
	if [ $prefix != "dingxiang" -a $prefix != "mine" ]; then
		echo "参数错误. 正确的参数只能是1个: dingxiang 或者 mine ."
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
	local used_objs_latest=${input}"/used_objs_backup/latest"
	local out=${output}"/data_for_tuqu/data_index."${prefix}.${today}

####################################################################################
# 配置文件
# 每日PM的需求数据数量 
	local type_demand_amount="conf/"${prefix}"_type_demand"
	local total_type_demand="conf/total_type_demand"
# 需求中定向和挖掘的需求比例
	local dx_vs_mine="conf/dingxiang_vs_mine"

		
	echo -e "2. 开始选择数据 ${prefix}..."
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
#		for(type in type_selected){
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

	cp ${used_objs} ${used_objs_backup}
#	cp ${temp}.used_objs ${used_objs_backup}
	if [ ${?} -ne 0 ]
	then
		echo -e "备份${used_objs}失败!"
		exit 1;
	fi;

	echo -e "	选择数据完成，输出文件为 ${out}"
}

restore_used_objs
if [ $? -ne 0 ]; then
	echo "恢复used_objs失败!"
fi

stat_data 
if [ $? -ne 0 ]; then
	echo "恢复used_objs失败!"
fi

select_data "dingxiang"
if [ $? -ne 0 ]; then
	echo "选择定向数据失败."
fi

echo "开始选择挖掘数据..."
select_data "mine"
if [ $? -ne 0 ]; then
	echo "挖掘数据选择失败."
fi


