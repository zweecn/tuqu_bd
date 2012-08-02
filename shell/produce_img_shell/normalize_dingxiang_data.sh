#!/bin/bash
### usage �����ݸ�ʽ��Ϊͳһ���ֶ�����

#############################################################################
# �����ļ�
#
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"

# ��������ļ�
objs_dingxiang=${input}"/objs_all";
output=${swap}"/dingxiang_data_normalized";

#############################################################################
# ���뿪ʼ
#

awk -F '\t' '{
    # objURL    fromURL     tags
    if (!mark[$8]) {
		print $8"\t"$9"\t"$13;
		mark[$8] = 1;
	}
}' ${objs_dingxiang} > ${output}

if [ ${?} -ne 0 ]
then 
    echo "��һ�����򣨺���������ʧ��!";
    exit 1;
fi;
