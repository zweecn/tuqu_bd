#!/bin/bash
function check_file_exist
{
	echo "[���]	����ļ��Ƿ����..."

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
		
	echo "[����]	�����ļ�������."
}

function select_data
{
	if [ $# -ne 1 ];then
		echo "[����]	��������������ȷ�Ĳ���������1."
		exit 1
	fi
	local prefix=$1
	if [ $prefix != "dingxiang" -a $prefix != "mine" ]; then
		echo "[����]	��������. ��ȷ�Ĳ���ֻ����1��: dingxiang ���� mine ."
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
	local out=${output}"/data_for_tuqu/data_index."${prefix}.${today}

####################################################################################
# �����ļ�
# ÿ��PM�������������� 
	local type_demand_amount="conf/"${prefix}"_type_demand"
	local total_type_demand="conf/total_type_demand"
# �����ж�����ھ���������
	local dx_vs_mine="conf/dingxiang_vs_mine"

		
	echo -e "[��ʼ]	��ʼѡ������ ${prefix}..."
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
		echo -e "[����]	�������� ${temp}.candidate ʧ��."
		exit 1;
	fi;

### �����ɢobj��ʹ��obj���ļ��е�����ƽ���ֲ�
	awk -F '\t' '{
		print $1"\t"$2"\t"$3"\t"$4"\t"rand();
	}' ${temp}.candidate | sort -t '	' -n -k5,5 | cut -f1,2,3,4 > ${out};
	if [ ${?} -ne 0 ]
	then
		echo -e "[����]	�����ɢ����objʧ��!";
		exit 1;
	fi;
	cat ${temp}.used_objs >> ${used_objs};
	if [ ${?} -ne 0 ]
	then
		echo -e "[����]	���� ${used_objs} ʧ��!";
		exit 1;
	fi;

	cp ${used_objs} ${used_objs_backup}
#	cp ${temp}.used_objs ${used_objs_backup}
	if [ ${?} -ne 0 ]
	then
		echo -e "[����]	����${used_objs}ʧ��!"
		exit 1;
	fi;

	echo -e "[���]	ѡ��������ɣ�����ļ�Ϊ ${out}"
}

function merge_dingxiang_mine
{
	echo -e "[��ʼ]	��ʼ�ϲ����ɵĶ������ݺ��ھ�����..."
	local today=`date +%Y%m%d`
	local dingxiang="data/output/data_for_tuqu/data_index.dingxiang."${today}
	local mine="data/output/data_for_tuqu/data_index.mine."${today}
	local out="data/output/data_for_tuqu/data_index."${today}
	
	awk -F '\t' '{
		print $1 "\t" $2 "\t" $3 "\t" $4 "\t" rand();
	}' ${dingxiang} ${mine} | sort -k5 -n | cut -d'	' -f 1,2,3,4 > ${out} 

	echo -e "[���]	�������ݳɹ�. ���Ϊ ${out}"
}

echo "==============================================================================="
echo -e "[��ʼʱ��]	`date` "

# 	1. ����ļ��Ƿ����
check_file_exist
if [ $? -ne 0 ]; then 
	echo "[����]	ȱ�������ļ����������ļ�������conf��dataĿ¼�Ƿ�����."
	exit 1
fi

#	2. ѡ��������
select_data "dingxiang"
if [ $? -ne 0 ]; then
	echo "[����]	ѡ��������ʧ��."
fi

#	3. ѡ���ھ�����
select_data "mine"
if [ $? -ne 0 ]; then
	echo "[����]	�ھ�����ѡ��ʧ��."
fi

#	4. �ϲ��������ݺ��ھ����ݲ���ɢ
merge_dingxiang_mine
if [ $? -ne 0 ]; then
	echo "[����]	�ϲ��������ݺ��ھ�����ʧ��."
fi

echo -e "[����ʱ��]	`date` "
echo "==============================================================================="
