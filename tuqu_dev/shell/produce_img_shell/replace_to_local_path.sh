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
out=${input}"/objs_local_data"
remote_host="img@jx-apptest-img04.vm.baidu.com"
remote_path="/home/img/shiym/dingxiang/work/client/"
local_path=`pwd`"/data/"
today=`date +%Y%m%d`

#sed -e 's/\/home\/img\/shiym\/dingxiang\/work\/client/data/g' ${input} > ${output}

# �滻ʱ��������ת������������ַ�#��Ϊ�ָ���/
sed -e "s#${remote_path}#${local_path}#g"  ${in} > ${out}

if [ $? -ne 0 ]
then
	echo 'Replace path to local path failed.'
	exit 1
fi

mv ${in} ${in}.bak.${today}
cp ${out} ${in}

