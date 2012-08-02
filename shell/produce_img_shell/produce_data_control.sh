#!/bin/bash
## ���������ͼƬ�����Ա�ͼȤ���

### 1. ���ɱ���·��
#ssh img@jx-apptest-img04.vm "cd /home/img/shiym/dingxiang/work/client && ./format_path_jinsong.sh";
#if [ ${?} -ne 0 ]
#then 
#    echo "Զ������ͼƬ·������ʧ�ܣ�";
#    exit 1;
#fi;
### 2. ����·��index
#scp img@jx-apptest-img04.vm:/home/img/shiym/dingxiang/work/client/formated_urls_jinsong/objs_local_path data/objs_local_path
#if [ ${?} -ne 0 ]
#then
#    echo "����Զ�����ɵ�ͼƬ·������ʧ��!";
#    exit 1;
#fi;

############################################################################
### 1-2. ����Ľű����1-2���� �����ٶȷ�������image��ַ,
# 		Ҳ�����ڿ�ʼ��ʱ�����г�ʼ��
#./shell/produce_img_shell/gen_baidu_server_img_path.sh 


############################################################################
### 3. ���ɿ�������Դ
############################################################################
echo "��ʼ��������..."

## 3.1 ��������������
./shell/produce_img_shell/normalize_dingxiang_data.sh;
if [ ${?} -ne 0 ]
then 
    echo "�������ݸ�ʽ��ʧ�ܣ�";
    exit 1;
fi;

## 3.2 �����ھ�����
./shell/produce_img_shell/normalize_mining_data.sh
if [ ${?} -ne 0 ]
then
    echo "�ھ����ݸ�ʽ��ʧ�ܣ�";
    exit 1;
fi;

## 3.3 ��ʽ����������
./shell/produce_img_shell/format_dingxiang.sh
if [ ${?} -ne 0 ]
then 
    echo "�ϲ�����ʧ�ܣ�";
    exit 1;
fi;

## 3.4 ��ʽ���ھ�����
./shell/produce_img_shell/format_mine.sh
if [ ${?} -ne 0 ]
then 
    echo "�ϲ�����ʧ�ܣ�";
    exit 1;
fi;

############################################################################
### 4. ѡ������
############################################################################
echo "ѡ������..."

./shell/produce_img_shell/select_data.sh
if [ ${?} -ne 0 ]
then 
    echo "ѡ������ʧ�ܣ�";
    exit 1;
fi;

############################################################################
# 5. �滻HTML�ַ�
############################################################################
echo "����Ƿ�HTML�ַ�..."
./shell/produce_img_shell/clear_html_char.sh 
if [ ${?} -ne 0 ]
then 
    echo "�滻HTML�ַ�ʧ��!";
    exit 1;
fi;

############################################################################
# 6. ���䵽Զ�̻���
############################################################################
echo "��������..."
./shell/produce_img_shell/scp_to_remote.sh
if [ ${?} -ne 0 ]
then 
    echo "���䵽Զ�̻���ʧ�ܣ�"
    exit 1;
fi;
