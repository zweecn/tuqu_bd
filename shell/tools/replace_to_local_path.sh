#!/bin/bash
###################################################################################
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
###################################################################################

in=${input}"/objs_local_path"
out=${temp}".objs_local_path"
base_path=`pwd`"/data/res"


awk -F 'res' -v base="${base_path}" '{
	print base$2; 
}' ${in} > ${out}

cp ${out} ${in}
