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

echo "��ʼ��������..."
date

echo "��ʼ��ʽ����������..."
###################################################################################
#
#	I.		 ���ɶ��������
#
# 	1.	�������������� ��һ����ʽ��
./shell/produce_img_shell/normalize_dingxiang_data.sh;
if [ ${?} -ne 0 ]
then 
    echo "�������ݸ�ʽ��ʧ��."
    exit 1;
fi

#	2.	��һ����ʽ���������ݣ�����ɸѡ���滻�ȵ�
echo "source format_data.sh ..."
source ./shell/produce_img_shell/format_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
format_data "dingxiang"
if [ $? -ne 0 ]
then
	echo "��һ����ʽ����������ʧ��."
	exit 1
fi
echo "�������ݸ�ʽ�����."
date

echo "��ʼ��ʽ���ھ�����..."
###################################################################################
#
#	II.		 �����ھ������
#
# 	1.	�ھ����� ��һ����ʽ��
./shell/produce_img_shell/normalize_mining_data.sh
if [ ${?} -ne 0 ]
then 
    echo "�ھ����ݸ�ʽ��ʧ��."
    exit 1;
fi

#	2.	��һ����ʽ���ھ����ݣ�����ɸѡ���滻�ȵ�
echo "source format_data.sh ..."
source ./shell/produce_img_shell/format_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
format_data "mine"
if [ $? -ne 0 ]
then
	echo "��һ����ʽ����������ʧ��."
	exit 1
fi
echo "��ʽ���ھ��������."
echo "��ʽ�������������."
date

