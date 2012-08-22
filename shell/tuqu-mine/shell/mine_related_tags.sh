#!/bin/bash

temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
input="./data/source_valid"
person_name="./conf/person"

output="./data/tag_list"
show_tag="./data/tag_list_show"


# Ŀ��tag��
# 1����Ů˧��  : �������
# 		����   : ����
# 2���羰/���� : ����ʻ���ͬ��ʱ���������
# 3��Ȥζ/��Ц : ����ʻ���ͬ��ʱ����������������͡��ض�ϵ�����顢
# 		����   :
# 4��ʱ��/����/���� : ����ʻ���ͬ��ʱ�����������͡����ݣ�
# 5���Ҿ�/װ��      : ������͡����ݣ�


## 1. bi of tag
awk -F'	' '{
	n = split($NF, arr, "\\$\\$");

	delete hash;
	idx = 0;
	for(i = 1; i <= n; i++)
	{
		if(arr[i] in hash)
		{
			continue;
		}
		
		idx++;
		arr[idx] = arr[i];
		hash[arr[i]] = 1;
	}
	n = idx;
		
	for(i = 1; i <= n; i++)
	{
		si[arr[i]]++;
		for(j = i + 1; j <= n; j++)
		{
			bi[arr[i]"\t"arr[j]]++;
			bi[arr[j]"\t"arr[i]]++;
		}
	}
} END {
	for(i in bi)
	{
		print i"\t"bi[i] > "'${temp}.'bi";
	}
	for(i in si)
	{
		print i"\t"si[i] > "'${temp}.'si";
	}
}' ${input}
if [ ${?} -ne 0 ]
then
	echo "calc term freq failed!"
	exit 1
fi

## 2. support
awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else
	{
		print $0"\t"($3 / a[$2]);
	}
}' ${temp}.si ${temp}.bi > ${temp}.sp
if [ ${?} -ne 0 ]
then
    echo "calc sp failed!"
    exit 1
fi

## 3. tag type
awk -F'	' 'BEGIN {
	OFS = "\t";
	seed_tag[1] = "�Ը� �崿 ������Ů ��ģ ʪ��д�� ������� ��Ů ˧�� ����";
	seed_tag[2] = "�羰	���� ���� ��ɫ ���� ������ ������� ���� �������� �Ǳ� ɳ̲ ���� ɭ�� ɳĮ ��ԭ";
	seed_tag[3] = "Ȥζ ��� ��Ц Ȥͼ �� ���˿ɰ� �ȳ� ����� ��̬ ��è ��Ц�� ������ �������� а��С���� ���";
	seed_tag[4] = "���� ʱװ ���� ���� ���� ŷ�� ���� ��ϵ ��ϵ ����ȹ T�� �߸�Ь ��ɴ";
	seed_tag[5] = "ŷʽ ���� ���� ����� ���� ��ԡ �Ҿ� �Ҿ�";
	seed_tag[6] = "��ʳ ���� ��ʳ ��Ʒ ��ʳ ���� ���� ��� �決 ΢��¯ ���� ��˿ ���� �ɿ��� ����� ���� ������";
    seed_tag[7] = "��Ӱ ӳ�� ��Ƭ ���� ���� ���� LOMO Ψ�� ���� è ��ͬ ���Ϻ� ��ɴ��Ӱ";
    seed_tag[8] = "������� ���� ��� DESIGN ƽ����� ��װ��� ������ ��Ʒ��� ������� ���� ��� ����ֱ�� ������ ����.���ϵ� ��ɫ ���� �Ļ� ���� design";
    seed_tag[9] = "������Ϸ ���� ���� �廭 ��Ϸ COSPLAY cosplay ��Ӱ���� �������� ���� ���� �궷�� ������";
    seed_tag[10]="��ױ���� ����/���� �������� ���� ױ�� ���� ��ױ ױ�� ��ױ ��ͫ �� ���� ���� ���� ��ױ";
	level = 1;

	for(i = 6; i <= 10; i++)
	{
		n = split(seed_tag[i], arr, " ");
		for(j in arr)
		{
			key[arr[j]] = i;
		}
	}
} {
	if(($1 in key) && $3 >= 50)
	{
		$4 *= 1000;
		if($4 > 500)
		print key[$1]"\t"$0;
	}
}' ${temp}.sp | sort -t'	' -r -n -k5,5 | sort -t'	' -s -k1,1 > ${temp}.type
if [ ${?} -ne 0 ]
then
	echo "calc tag type failed!"
	exit 1
fi

awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else
	{
		print $3"\t"a[$3]"\t"$1;
	}
}' ${temp}.si ${temp}.type | sort -t'	' -r -n -k2,2 | sort -t'	' -s -n -k3,3 | uniq > ${temp}.show
if [ ${?} -ne 0 ]
then
	echo "filt tag type failed!"
	exit 1
fi

## 4. high freq tag
awk -F'	' '{
	if($2 > 50)
	{
		print;
	}
}' ${temp}.si > ${temp}.high_freq
if [ ${?} -ne 0 ]
then
	echo "calc high freq tag failed!"
	exit 1
fi

## output
rm -rf ${output}.bak
mv ${output} ${output}.bak
cp ${temp}.si ${output}

rm -rf ${show_tag}.bak
mv ${show_tag} ${show_tag}.bak
cp ${temp}.show ${show_tag}

exit 0

