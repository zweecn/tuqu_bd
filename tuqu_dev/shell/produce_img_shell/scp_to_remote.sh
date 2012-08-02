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

# ��Ҫ����������
index=${output}"/data_for_tuqu/data_index."`date +%Y%m%d`;
# Զ�̻����������ļ�
remote_server=`cat conf/remote_server`
# ��Ҫ�����������ļ���
index_filename="data_index."`date +%Y%m%d`

echo -e "��ʼ������Զ������: ${remote_server}"

scp ${index} ${remote_server}
if [ ${?} -ne 0 ]
then
    echo "����������Զ�̻���ʧ��!"
    exit 1
fi

echo -e "������Զ�������ɹ����ļ�Ϊ ${remote_server}/${index_filename}"

