#!/bin/bash

###################################################################################
#
#	�ű�����: 
#		���ɿ�������Դ�����ƽű� ���������ͼƬ�����Ա�ͼȤ���
#	��3�������:
#		I.		 ���ɶ��������
#		II.		 �����ھ������
#
###################################################################################

echo "=============================================================================="
echo "[��ʼ]	��ʼ��������..."
echo -e "[ʱ��] `date`"
start_time=`date +%s`

rm -rf data/temp/*

###################################################################################
#
#	I.		 ���ɶ��������
#
# 	1.	�������������� ��һ����ʽ��
echo "[STEP 1] ��ȡ�������� obj_url / from_url / tag ..."
./shell/produce_img_shell/normalize_dingxiang_data.sh;
if [ ${?} -ne 0 ]
then 
    echo "[����]	�������ݸ�ʽ��ʧ��."
    exit 1;
fi

#	2.	��һ����ʽ���������ݣ�����ɸѡ���滻�ȵ�
echo "[STEP 2] ��ʽ���������� ..."
echo "	source format_data.sh ..."
source ./shell/produce_img_shell/format_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
format_data "dingxiang"
if [ $? -ne 0 ]
then
	echo "[����]	��һ����ʽ����������ʧ��."
	exit 1
fi

echo "[FINISHED] �������ݸ�ʽ�����."
end_dingxiang=`date +%s`
echo "[ʱ��] `date` �������ݴ����ʱ $(($end_dingxiang - $start_time)) s"

###################################################################################
#
#	II.		 �����ھ������
#
# 	1.	�ھ����� ��һ����ʽ��
echo "[STEP 1] ��ȡ�ھ����� obj_url / from_url / tag ..."
./shell/produce_img_shell/normalize_mining_data.sh
if [ ${?} -ne 0 ]
then 
    echo "[����]	�ھ����ݸ�ʽ��ʧ��."
    exit 1;
fi

#	2.	��һ����ʽ���ھ����ݣ�����ɸѡ���滻�ȵ�
echo "[STEP 2] ��ʽ���ھ����� ..."
echo "	source format_data.sh ..."
source ./shell/produce_img_shell/format_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
format_data "mine"
if [ $? -ne 0 ]
then
	echo "[����]	��һ����ʽ����������ʧ��."
	exit 1
fi

echo "[FINISHED] ��ʽ���ھ��������."
echo "[����]��ʽ�������������."
end_mine=`date +%s`
echo "[ʱ��] `date` �ھ����ݴ����ʱ $(($end_mine - $end_dingxiang)) s"
echo "[�ܺ�ʱ] $(($end_mine - $end_dingxiang)) s"
echo "=============================================================================="
