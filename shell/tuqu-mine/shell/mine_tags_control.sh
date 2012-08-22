#!/bin/bash 

echo "start select_valid_src...";
## 0. select_valid_src.sh
./shell/select_valid_src.sh
if [ ${?} -ne 0 ]
then
	echo "select valid src failed!"
	exit 1
fi

## 1. mine related tags
#./shell/mine_related_tags.sh
if [ ${?} -ne 0 ]
then
	echo "mine related tags failed!"
	exit 1
fi
echo "start remove_useless_info...";
## 2. remove useless info
./shell/remove_useless_info.sh
if [ ${?} -ne 0 ]
then
	echo "remove useless info failed!"
	exit 1
fi

echo "start add_sus_tag...";
## 3. add sus tag
./shell/add_sus_tag.sh
if [ ${?} -ne 0 ]
then	
	echo "add sus tag failed!"
	exit 1
fi

## 3.1 ����PM��������ͣ�7�����ͣ�����Ů��˧��ȣ�
## �ŵ������
#./shell/merge_pm_tag.sh
if [ ${?} -ne 0 ]
then	
	echo "�ϲ�PM��tagʧ�ܣ�"
	exit 1
fi

## 3.2 remove objs in blacklist
#./shell/merge_black_list.sh
if [ ${?} -ne 0 ]
then
	echo "remove objs in blaclist failed!"
	exit 1
fi

echo "start add_thumb...";
### 4. add thumb
./shell/add_thumb.sh
if [ ${?} -ne 0 ]
then
	echo "add thumb failed!"
	exit 1
fi

## 5. for pg
#./shell/for_pinggu.sh
if [ ${?} -ne 0 ]
then
	echo "for pinggu failed!"
	exit 1
fi

## 6. pm�����tag���˹������tag��merge
#./shell/merge_all_tags.sh
if [ ${?} -ne 0 ]
then
	echo "merge all tags!"
	exit 1
fi
