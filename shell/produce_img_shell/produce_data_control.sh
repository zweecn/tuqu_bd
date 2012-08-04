#!/bin/bash

###################################################################################
#
#	�ű�����: 
#		���ɿ�������Դ�����ƽű� ���������ͼƬ�����Ա�ͼȤ���
#	��3�������:
#		I.		 ���ɶ��������
#		II.		 �����ھ������
#		III.	 ѡ������
#		IV.		 �����ɵ����ݽ����ƺ���(�滻HTML�ַ������䵽Զ������)
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

echo "��ʼѡ������..."
###################################################################################
#
#	III.	 ѡ������
#
# 	1. ѡ��������
#echo "source select_data.sh ..."
#source ./shell/produce_img_shell/select_data.sh
#if [ $? -ne 0 ]
#then
#	echo "source failed."
#	exit 1
#fi
#select_data "dingxiang"
#if [ $? -ne 0 ]
#then
#	echo "ѡ��������ʧ��."
#	exit 1
#fi
#
# 	2. ѡ���ھ�����
#echo "source select_data.sh ..."
#source ./shell/produce_img_shell/select_data.sh
#if [ $? -ne 0 ]
#then
#	echo "source failed."
#	exit 1
#fi
#select_data "mine"
#if [ $? -ne 0 ]
#then
#	echo "ѡ��������ʧ��."
#	exit 1
#fi

./shell/produce_img_shell/select_data.sh
if [ $? -ne 0 ]
then
	echo "ѡ������ʧ��."
	exit 1
fi


echo "ѡ���������."
date

echo "��ʼ�����ƺ���..."
###################################################################################
#		IV.	 �����ɵ����ݽ����ƺ���(�滻HTML�ַ������䵽Զ������)
#

# 	1. �滻HTML�ַ�
./shell/produce_img_shell/clear_html_char.sh 
if [ ${?} -ne 0 ]
then 
    echo "�滻HTML�ַ�ʧ��!";
    exit 1;
fi;

#	2. ���䵽Զ�̻���
./shell/produce_img_shell/scp_to_remote.sh
if [ ${?} -ne 0 ]
then 
    echo "���䵽Զ�̻���ʧ�ܣ�"
    exit 1;
fi;

echo "�ƺ������."
echo "�����������."
date

