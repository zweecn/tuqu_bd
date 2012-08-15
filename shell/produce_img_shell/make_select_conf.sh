#!/bin/bash

function restore_used_objs
{
	echo "0. ��ʼ����ǰ�����used_objs�ָ�used_objs..."
	local used_objs="data/input/used_objs"
	local backup_dir="data/input/used_objs_backup"

	local yesterday=`date -d"1 day ago" +"%Y%m%d"`
	local two_days_ago=`date -d"2 day ago" +"%Y%m%d"`
	local three_days_ago=`date -d"3 day ago" +"%Y%m%d"`

	all_used=`ls ${backup_dir}/*${yesterday}*`
	if [ $? -ne 0 ]; then
		echo "�����used_objs�����ڣ�����ǰ���."
		all_used=`ls ${backup_dir}/*${two_days_ago}*`
		if [ $? -ne 0 ]; then
			all_used=`ls ${backup_dir}/*${three_days_ago}*`
			if [ $? -ne 0 ]; then
				echo "ǰ���used_objs�����ڣ��������е�."
				all_used=`ls ${backup_dir}`
				if [ $? -ne 0 ]; then
					echo "û�б��ݵ�used_objs��ʧ��!"
					exit 1
				fi
			fi
		fi
	fi

	echo "���������ļ��ָ�used_objs:"
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
	echo "�ָ�used_objs���."
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
# �����ļ�
# ÿ��PM�������������� 
	local total_type_demand="conf/total_type_demand"
# �����ж�����ھ���������
	local dx_vs_mine="conf/dingxiang_vs_mine"

	local dingxiang_type_demand_amount="conf/dingxiang_type_demand"
	local mine_type_demand_amount="conf/mine_type_demand"
	
	echo -e "[��ʼ]	��ʼͳ�����ݺͰ�����������Ҫ����..."
	awk -F '[\t]' -v dx_d="${dingxiang_type_demand_amount}" -v mi_d="${mine_type_demand_amount}" -v dx_null_type="${temp}.dingxiang_null_type" -v mi_null_type="${temp}.mine_null_type" '{
		
		if (FILENAME==ARGV[1]) {
			type_demands[$1]=$2;
			total_needed+=$2;
		} else if (FILENAME==ARGV[2]) {
			dx_need = total_needed * $1 / ($1+$2);
			mi_need = total_needed - dx_need;
			print "\t�������ݺ��ھ����ݷֱ���Ҫ "dx_need" �� "mi_need " ��";
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
		print "\t��������:\tTotal:" dx_total "\tNeed:" dx_need;
		print "\t���л��е�ͼƬ����Ϊ:";
		print "\t-------------------------------------------------"
		
		dingxiang_min_day = 1000; 	
		total_dingxiang_cnt = 0;
		for (t in dx_cnt) {
			need_t = dx_need*dx_cnt[t]/dx_total;
			if (need_t != 0 && dingxiang_min_day > dx_cnt[t] / need_t) {
				dingxiang_min_day = dx_cnt[t] / need_t;
			}
			split(t, arr, "-");

#			����ÿ�������ϴ������ݲ���������	
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
		print "\t�ھ�����:\tTotal:" mi_total "\tNeed:" mi_need;
		print "\t���л��е�ͼƬ����Ϊ:";
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

		## ���������ھ����ݵĲ�����	
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
		print "[����]	�������ݴ�Լ������֧�� " dingxiang_min_day " �죬�ھ����ݴ�Լ������֧�� " mine_min_day " ��"
		print "[����]	���������ܹ�ÿ������ " total_dingxiang_cnt " �ţ��ھ�����ÿ������ " total_mine_cnt " ��."
		if (dx_total < dx_need || mi_total < mi_need) {
			print "\t����:�������������㣬�����޷�ѡ��. ����ʣ��/��������=" dx_total"/"dx_need " �ھ�ʣ��/�ھ�����=" mi_total"/"mi_need;
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
		print "[����]	����	�ھ���������	��������	֧������"
		for (t in mine_cnt) {
			print "\t" t"\t"mine_cnt[t]"\t" mine_cnt_total[t] "\t" mine_cnt_total[t]/mine_cnt[t];
		}
		print "\t-------------------------------------------------"
		print "[����]	����	������������	��������	֧������"
		for (t in dingxiang_cnt) {
			print "\t" t"\t"dingxiang_cnt[t]"\t" dingxiang_cnt_total[t] "\t" dingxiang_cnt_total[t]/dingxiang_cnt[t];
		}
		print "\t-------------------------------------------------"
	}' ${dingxiang_type_demand_amount} ${mine_type_demand_amount}
	

	echo -e "[���]	�Ѱ��ն���������ռ�������ɸ��������ݣ����Ϊ ${dingxiang_type_demand_amount}"
	echo -e "[���]	�Ѱ����ھ�������ռ�������ɸ��������ݣ����Ϊ ${mine_type_demand_amount}"
	echo -e "[����]	����һ������û�д����ͣ����Ϊ ${temp}.dingxiang_null_type"
	echo -e "[����]	����һ������û�д����ͣ����Ϊ ${temp}.mine_null_type"
}

# 	1. �ָ�used_objs
#restore_used_objs
#if [ $? -ne 0 ]; then
#	echo "�ָ�used_objsʧ��!"
#fi


#	2. ͳ������
stat_data 
if [ $? -ne 0 ]; then
	echo "ͳ������ʧ��!"
fi


