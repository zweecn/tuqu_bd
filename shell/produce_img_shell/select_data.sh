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
	
	echo -e "1. ��ʼͳ�����ݺͰ�����������Ҫ����..."
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
		print "\t��������:\tTotal:" dx_total "\tNeed:" dx_need;
		print "\t���л��е�ͼƬ����Ϊ:";
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
		print "\t�ھ�����:\tTotal:" mi_total "\tNeed:" mi_need;
		print "\t���л��е�ͼƬ����Ϊ:";
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
			print "\t����:�������������㣬�����޷�ѡ��. ����ʣ��/��������=" dx_total"/"dx_need " �ھ�ʣ��/�ھ�����=" mi_total"/"mi_need;
		}
	}' ${total_type_demand} ${dx_vs_mine} ${used_objs} ${dingxiang_final_objs} ${mine_final_objs}

	echo -e "	�Ѱ��ն���������ռ�������ɸ��������ݣ����Ϊ ${dingxiang_type_demand_amount}"
	echo -e "	�Ѱ����ھ�������ռ�������ɸ��������ݣ����Ϊ ${mine_type_demand_amount}"
	echo -e "	����һ������û�д����ͣ����Ϊ ${temp}.dingxiang_null_type"
	echo -e "	����һ������û�д����ͣ����Ϊ ${temp}.mine_null_type"
}

function select_data
{
	if [ $# -ne 1 ];then
		echo "��������������ȷ�Ĳ���������1."
		exit 1
	fi
	local prefix=$1
	if [ $prefix != "dingxiang" -a $prefix != "mine" ]; then
		echo "��������. ��ȷ�Ĳ���ֻ����1��: dingxiang ���� mine ."
		exit 1
	fi

####################################################################################
#	��������Ŀ¼
# 	filename 		��������ִ�еĽű��ļ���
# 	temp			�����м����ɵ���ʱ�ļ�Ŀ¼
#	input			�������ԭʼ����Ŀ¼���ֹ��ṩ������
#	swap			���ű����������ű�������/����ļ�Ŀ¼�����ű�֮�䴫���������
#	output			�����������ļ�
#	today			��������ڣ���ʽ�������� "20120802"
	local filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
	local temp="./data/temp/"${filename}.${prefix}
	local input="./data/input"
	local swap="./data/swap/"${prefix}
	local output="./data/output"
	local today=`date +%Y%m%d`
####################################################################################

####################################################################################
# ��������ļ�
	local final_objs=${swap}"_final_objs_data"
	local used_objs=${input}"/used_objs"
	local used_objs_backup=${input}"/used_objs_backup/used_objs.${prefix}.after."${today}
	local used_objs_latest=${input}"/used_objs_backup/latest"
	local out=${output}"/data_for_tuqu/data_index."${prefix}.${today}

####################################################################################
# �����ļ�
# ÿ��PM�������������� 
	local type_demand_amount="conf/"${prefix}"_type_demand"
	local total_type_demand="conf/total_type_demand"
# �����ж�����ھ���������
	local dx_vs_mine="conf/dingxiang_vs_mine"

		
	echo -e "2. ��ʼѡ������ ${prefix}..."
### ѡ������
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
		print "\tѡ����������:"
		print "\t-------------------------------------------------";
#		for(type in type_selected){
		for(type in type_demands){
			print "\t"type"\t"type_selected[type]"/"type_demands[type];
			count+=type_selected[type];
		}
		print "\t�����������С������������ʵ�ʲ������� " count " ��.";
		print "\t-------------------------------------------------";
		if(count!=total_needed){
			print "��������ʧ�ܣ����������ļ��Ϳ����������Ƿ����. Need:" total_needed ", Generate:" count;
			exit 1;
		}
		for(type in type_selected){
			if(type_selected[type]<type_demands[type]){
				print "�������ݹ���! ����data_indexʧ��." type " need:" type_demands[type] ", Generate:" type_selected[type];
				exit 1;
			}
		}
	}' ${type_demand_amount} ${used_objs} ${final_objs};
	if [ ${?} -ne 0 ]
	then
		echo "��������"${out}"ʧ��!";
		exit 1;
	fi;

### �����ɢobj��ʹ��obj���ļ��е�����ƽ���ֲ�
	awk -F '\t' '{
		print $1"\t"$2"\t"$3"\t"$4"\t"rand();
	}' ${temp}.candidate | sort -t '	' -n -k5,5 | cut -f1,2,3,4 > ${out};
	if [ ${?} -ne 0 ]
	then
		echo "�����ɢ����objʧ��!";
		exit 1;
	fi;
	cat ${temp}.used_objs >> ${used_objs};
	if [ ${?} -ne 0 ]
	then
		echo "�ϲ�ʹ�ù���objʧ�ܣ�";
		exit 1;
	fi;

	cp ${used_objs} ${used_objs_backup}
#	cp ${temp}.used_objs ${used_objs_backup}
	if [ ${?} -ne 0 ]
	then
		echo -e "����${used_objs}ʧ��!"
		exit 1;
	fi;

	echo -e "	ѡ��������ɣ�����ļ�Ϊ ${out}"
}

restore_used_objs
if [ $? -ne 0 ]; then
	echo "�ָ�used_objsʧ��!"
fi

stat_data 
if [ $? -ne 0 ]; then
	echo "�ָ�used_objsʧ��!"
fi

select_data "dingxiang"
if [ $? -ne 0 ]; then
	echo "ѡ��������ʧ��."
fi

echo "��ʼѡ���ھ�����..."
select_data "mine"
if [ $? -ne 0 ]; then
	echo "�ھ�����ѡ��ʧ��."
fi


