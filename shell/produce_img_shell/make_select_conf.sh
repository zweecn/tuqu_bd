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
	
	echo -e "[开始]	开始统计数据和按比例生成需要数据..."
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
		print "\t-------------------------------------------------"
		print "\t定向数据:\tTotal:" dx_total "\tNeed:" dx_need;
		print "\t库中还有的图片数据为:";
		print "\t-------------------------------------------------"
		
		dingxiang_min_day = 1000; 	
		total_dingxiang_cnt = 0;
		for (t in dx_cnt) {
			need_t = dx_need*dx_cnt[t]/dx_total;
			if (need_t != 0 && dingxiang_min_day > dx_cnt[t] / need_t) {
				dingxiang_min_day = dx_cnt[t] / need_t;
			}
			split(t, arr, "-");

#			限制每个大类上传的数据不超过需求	
#			if (dx_types[arr[2]] + need_t > type_demands[arr[2]]) {
#				need_t = type_demands[arr[2]] - dx_types[arr[2]];	
#			} 

#			if (need_t > type_demands[arr[2]]) {
#				need_t = type_demands[arr[2]];
#			}
#			type \t need_count \t now_left_count
			printf("%s\t%d\t%d\n", t, need_t, dx_cnt[t]) > dx_d;
			printf("\t%s\t%d\n", t, dx_cnt[t]);
			dx_types[arr[2]] += need_t;
			
			total_dingxiang_cnt += need_t;
		}
		print "\t-------------------------------------------------"
		print "\t挖掘数据:\tTotal:" mi_total "\tNeed:" mi_need;
		print "\t库中还有的图片数据为:";
		print "\t-------------------------------------------------"
		
		total_mine_cnt = 0;
		delete type_need_tmp;
		no_zero_type_cnt = 0;
		for (t in mi_cnt) {
			need_t = type_demands[t] - dx_types[t];
			if (need_t < 0) {
				need_t = 0;
			}
			
#			printf("%s\t%d\t%d\n", t, need_t, mi_cnt[t]) > mi_d;
#			printf("\t%s\t%d\n", t, mi_cnt[t]);
			
			type_need_tmp[t] = need_t;
			total_mine_cnt += need_t;
			if (need_t != 0) {
				no_zero_type_cnt++;
			}
		}

		## 以下修正挖掘数据的产生量	
		minus = 0;
		if (total_mine_cnt > mi_need) {
			minus = (total_mine_cnt - mi_need) / no_zero_type_cnt;	
		}
		total_mine_cnt = 0;
		mine_min_day = 1000; 
		for (t in mi_cnt) {
			need_t = type_need_tmp[t];
			if (need_t > minus) {
				need_t -= minus;
			}
			if (need_t != 0 && mine_min_day > mi_cnt[t] / need_t) {
				mine_min_day = mi_cnt[t] / need_t;
			}
			printf("%s\t%d\t%d\n", t, need_t, mi_cnt[t]) > mi_d;
			printf("\t%s\t%d\n", t, mi_cnt[t]);
			total_mine_cnt += need_t;
		}

		print "\t-------------------------------------------------"
		print "[结论]	定向数据大约还可以支撑 " dingxiang_min_day " 天，挖掘数据大约还可以支撑 " mine_min_day " 天"
		print "[结论]	定向数据总共每天生成 " total_dingxiang_cnt " 张，挖掘数据每天生成 " total_mine_cnt " 张."
		if (dx_total < dx_need || mi_total < mi_need) {
			print "\t警告:库中数据量不足，后续无法选择. 定向剩余/定向需求=" dx_total"/"dx_need " 挖掘剩余/挖掘需求=" mi_total"/"mi_need;
		}
	}' ${total_type_demand} ${dx_vs_mine} ${used_objs} ${dingxiang_final_objs} ${mine_final_objs}
	
	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			split($1, arr, "-");
			type = arr[2];
			dingxiang_cnt[type] += $2;
			dingxiang_cnt_total[type] += $3;
		} else {
			mine_cnt[$1] += $2;
			mine_cnt_total[$1] += $3;
		}
	} END {
		print "\t-------------------------------------------------"
		print "[结论]	大类	挖掘数据需求	数据总量	支持天数"
		for (t in mine_cnt) {
			print "\t" t"\t"mine_cnt[t]"\t" mine_cnt_total[t] "\t" mine_cnt_total[t]/mine_cnt[t];
		}
		print "\t-------------------------------------------------"
		print "[结论]	大类	定向数据需求	数据总量	支持天数"
		for (t in dingxiang_cnt) {
			print "\t" t"\t"dingxiang_cnt[t]"\t" dingxiang_cnt_total[t] "\t" dingxiang_cnt_total[t]/dingxiang_cnt[t];
		}
		print "\t-------------------------------------------------"
	}' ${dingxiang_type_demand_amount} ${mine_type_demand_amount}
	

	echo -e "[输出]	已按照定向数据所占比例生成各大类数据，输出为 ${dingxiang_type_demand_amount}"
	echo -e "[输出]	已按照挖掘数据所占比例生成各大类数据，输出为 ${mine_type_demand_amount}"
	echo -e "[警告]	发现一堆数据没有大类型，输出为 ${temp}.dingxiang_null_type"
	echo -e "[警告]	发现一堆数据没有大类型，输出为 ${temp}.mine_null_type"
}

# 	1. 恢复used_objs
#restore_used_objs
#if [ $? -ne 0 ]; then
#	echo "恢复used_objs失败!"
#fi


#	2. 统计数据
stat_data 
if [ $? -ne 0 ]; then
	echo "统计数据失败!"
fi


