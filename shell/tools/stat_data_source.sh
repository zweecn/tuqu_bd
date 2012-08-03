#!/bin/bash
####################################################################################
#	��������Ŀ¼
# 	filename 		��������ִ�еĽű��ļ���
# 	temp			�����м����ɵ���ʱ�ļ�Ŀ¼
#	input			�������ԭʼ����Ŀ¼���ֹ��ṩ������
#	swap			���ű����������ű�������/����ļ�Ŀ¼�����ű�֮�䴫���������
#	output			�����������ļ�
#	today			��������ڣ���ʽ�������� "20120802"
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}.${prefix}
input="./data/input"
swap="./data/swap/"${prefix}
output="./data/output"
today=`date +%Y%m%d`
####################################################################################

#input="data/data_source";
used_objs=${input}"/used_objs";
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
        print type"\t|\t"count[type];
        total+=count[type];
    }
    print "total="total;
}' ${used_objs} ${input}
