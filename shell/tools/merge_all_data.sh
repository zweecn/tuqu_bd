#!/bin/bash

#   �ϲ� �������ݺ��ھ����ݵ�  final_objs_data
####################################################################################
#	��������Ŀ¼
# 	filename 		��������ִ�еĽű��ļ���
# 	temp			�����м����ɵ���ʱ�ļ�Ŀ¼
#	input			�������ԭʼ����Ŀ¼���ֹ��ṩ������
#	swap			���ű����������ű�������/����ļ�Ŀ¼�����ű�֮�䴫���������
#	output			�����������ļ�
#	today			��������ڣ���ʽ�������� "20120802"

filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
today=`date +%Y%m%d`
###################################################################################

dx_final_objs=${swap}"/dingxiang_final_objs_data.without_path"
mi_final_objs=${swap}"/mine_final_objs_data.without_path"
need="conf/img.need"
used_obj=${output}"/used_objs"
out=${swap}"/merge_final_objs_data.without_path"

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		split($6, arr, "-");
		if (!mark[1]) {
			print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"arr[2]"\t"rand();
			mark[$1] = 1;
		}
	} else if (FILENAME == ARGV[2]) {
		if (!mark[1]) {
			print $0"\t"rand();
			mark[$1] = 1;
		}
	}

}' ${dx_final_objs} ${mi_final_objs} | sort -n -k7 | cut -d '	' -f 1,2,3,4,5,6 > ${out}

echo "�ϲ���� ����� " ${out}
