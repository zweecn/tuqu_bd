#!/bin/bash
######################################################################################
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

# �����ļ�  ��Ҫ����������
index_dingxiang=${output}"/data_for_tuqu/data_index.dingxiang."${today}
index_mine=${output}"/data_for_tuqu/data_index.mine."${today}

# Զ�̻����������ļ�
remote_server=`cat conf/remote_server`
# ��Ҫ�����������ļ���

filename_dingxiang=`echo ${index_dingxiang} | awk -F'[./]' '{ print $(NF - 1)}'`
filename_mine=`echo ${index_mine} | awk -F'[./]' '{ print $(NF - 1)}'`

echo -e "��ʼ������Զ������: ${remote_server}"

scp ${index_dingxiang} ${remote_server}
if [ ${?} -ne 0 ]
then
    echo "����������Զ�̻���ʧ��!"
    exit 1
fi
echo -e "������Զ�������ɹ����ļ�Ϊ ${remote_server}/${filename_dingxiang}"

scp ${index_mine} ${remote_server}
if [ ${?} -ne 0 ]
then
    echo "����������Զ�̻���ʧ��!"
    exit 1
fi
echo -e "������Զ�������ɹ����ļ�Ϊ ${remote_server}/${filename_mine}"

