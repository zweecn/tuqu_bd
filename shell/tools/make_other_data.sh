#!/bin/bash

####################################################################################
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

final_objs=${swap}"/merge_final_objs_data"
need="conf/img.need"
used_obj=${input}"/used_objs"
out=${swap}"/other_4_base_data"
lack=${temp}".lack"

echo -e "��ʼѡ������..."

awk -F '\t' -v lack="${lack}.tmp" '{
	if (FILENAME == ARGV[1]) {
		need[$1] = 200;
	} else if (FILENAME == ARGV[2]){
		used[$1] = 1; 
	} else {
		split($2, tags, ",");
		for (i in tags) {
			if (tags[i] in need && need[tags[i]] > 0) {
				need[tags[i]]--;
				print $1"\t"$2"\t"$3"\t"$4;
			}
		}
	}
} END {
	for (i in need) {
		if (need[i] > 0) {
			print i"\t"need[i] > lack;
		}
	}
}' ${need} ${used_obj} ${final_objs} > ${out}.with_used

awk -F '\t' -v online="${out}.online" '{
	if (FILENAME == ARGV[1]){
		used[$1] = 1; 
	} else {
		if ($1 in used) {
			print > online;
			next;
		}
		print $0;
	}
}' ${used_obj} ${out}.with_used | awk -F '\t' '{
    print $0"\t"rand();
}' | sort -n -k5 | awk -F'\t' '{
    print $1"\t"$2"\t"$3"\t"$4;
}' > ${out}

sort -n -r -k2 ${lack}.tmp > ${lack}
rm ${lack}.tmp

echo -e "�ܹ������������Ϊ ${out}.with_used `wc -l ${out}.with_used | cut -d ' ' -f 1` ��"
echo -e "�����Ѿ�������ͼƬ�� ${out}.online `wc -l ${out}.online | cut -d' ' -f 1` ��"
echo -e "����Ҫ�����������Ϊ ${out} `wc -l ${out} | cut -d ' ' -f 1` ��"
echo -e "��ȱ�ٵ��������Ϊ ${lack}"
