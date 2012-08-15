#!/bin/bash
###################################################################################
#
#	�ű�����: 
#		�ھ����ݵĸ�ʽ�Ƚϻ��ң��������ݲ���Ҫ��
#		��˽��������ݸ�ʽ��Ϊ������Ҫ�����ݸ�ʽ��
#	��������ݸ�ʽΪ:
#		1. ${objs_mine}���ֶ�˵��
#			��\t�ָ��2�ֶ�Ϊobj_url����6�ֶ�Ϊfrom_url����3�ֶ�ΪԭʼͼƬ��tag
#			��4�ֶ�Ϊ�ھ��tag
#		2. ${input_other}���ֶ�˵��
#			obj_url \t from_url \t title \t tags
#	��ʽ��������ݸ�ʽΪ:
#		obj_url \t from_url	\t tags
#
###################################################################################
#	��������Ŀ¼
# 	filename 		��������ִ�еĽű��ļ���
# 	temp			�����м����ɵ���ʱ�ļ�Ŀ¼
#	input			�������ԭʼ����Ŀ¼���ֹ��ṩ������
#	swap			���ű����������ű�������/����ļ�Ŀ¼�����ű�֮�䴫���������
#	output			�����������ļ�
#	today			��������ڣ���ʽ�������� "20120802"
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
today=`date +%Y%m%d`
###################################################################################

# ��������ļ�
objs_mine=${input}"/output.thumb";
input_other=${input}"/gaoxiaoo_idsoo_kaixin001_laifu_taitaitang.out";
out=${swap}"/mine_data_normalized";

###################################################################################
# ���뿪ʼ
#

awk -F '\t' '{
    if (FILENAME == ARGV[1]) {
		# objURL    fromURL     tags
		parser_tag=$3;
		mining_tag=$4;
		if(parser_tag!=""){
			tag_str=parser_tag;
		}else{
			tag_str=mining_tag;
		}
    	if (!mark[$2]) {
			print $2"\t"$6"\t"tag_str;
			mark[$2] = 1;
		}
	} else {
		if (!mark[$1]) {
			print $1"\t"$2"\t"$4;
			mark[$1] = 1;
		}
	}
}' ${objs_mine} ${input_other}  > ${out}

if [ ${?} -ne 0 ]
then 
    echo "[����]	��һ���ھ�����ʧ��!";
    exit 1;
fi;

echo -e "[���]	��ʽ���ھ��������. ����ļ�Ϊ ${out}"
