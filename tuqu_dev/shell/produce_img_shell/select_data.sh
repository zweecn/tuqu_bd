#!/bin/bash
####################################################################################
#	��������Ŀ¼
# 	filename 		��������ִ�еĽű��ļ���
# 	temp			�����м����ɵ���ʱ�ļ�Ŀ¼
#	input			�������ԭʼ����Ŀ¼���ֹ��ṩ������
#	swap			���ű����������ű�������/����ļ�Ŀ¼�����ű�֮�䴫���������
#	output			�����������ļ�
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
####################################################################################

####################################################################################
# ��������ļ�
final_objs=${swap}"/final_objs_data";
used_objs=${output}"/used_objs";
used_objs_backup=${output}"/used_objs_backup/used_objs.bak";
out=${output}"/data_for_tuqu/data_index."`date +%Y%m%d`;

####################################################################################
# �����ļ�
# ÿ��PM��������������
type_demand_amount="conf/type_demand_amount";

echo "��ʼѡ������..."

### ѡ������
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
        print "��������ʧ�ܣ����������ļ��Ϳ����������Ƿ����.";
        exit 1;
    }
    for(type in type_selected){
        if(type_selected[type]<type_demands[type]){
            print "�������ݹ���! ����data_indexʧ�ܣ�����";
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

cp ${used_objs} ${used_objs_backup}.after.`date +%Y%m%d`
if [ ${?} -ne 0 ]
then
    echo -e "����${used_objs}ʧ��!"
	exit 1;
fi;

echo -e "ѡ��������ɣ�����ļ�Ϊ ${out}"
