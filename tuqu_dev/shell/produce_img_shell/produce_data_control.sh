#!/bin/bash

### ���ɿ�������Դ�����ƽű� ���������ͼƬ�����Ա�ͼȤ���

echo "��ʼ��������..."
date

### 1 ��������������
./shell/produce_img_shell/normalize_dingxiang_data.sh;
if [ ${?} -ne 0 ]
then 
    echo "�������ݸ�ʽ��ʧ�ܣ�";
    exit 1;
fi;

### 2 �����ھ�����
./shell/produce_img_shell/normalize_mining_data.sh
if [ ${?} -ne 0 ]
then 
    echo "�ھ����ݸ�ʽ��ʧ�ܣ�";
    exit 1;
fi;

### 3 �ϲ�
./shell/produce_img_shell/format_data.sh
if [ ${?} -ne 0 ]
then 
    echo "�ϲ�����ʧ�ܣ�";
    exit 1;
fi;

### 4. ѡ������
./shell/produce_img_shell/select_data.sh
if [ ${?} -ne 0 ]
then 
    echo "ѡ������ʧ�ܣ�";
    exit 1;
fi;

### 5. �滻HTML�ַ�
./shell/produce_img_shell/clear_html_char.sh 
if [ ${?} -ne 0 ]
then 
    echo "�滻HTML�ַ�ʧ��!";
    exit 1;
fi;

### 6. ���䵽Զ�̻���
./shell/produce_img_shell/scp_to_remote.sh
if [ ${?} -ne 0 ]
then 
    echo "���䵽Զ�̻���ʧ�ܣ�"
    exit 1;
fi;

echo "�����������."
date
