#!/bin/bash

####################################################################################
#
#	ͳ�ƻ�ʣ�¶�������
#
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

used_objs=${input}"/used_objs";
type_index="conf/type_index"
out=${temp}".dingxiang"
site_out=${temp}."sites"
dingxiang_amount=`cat conf/total_dingxiang_amount`

data=data/swap/dingxiang_final_objs_data.without_path

#if [ $# -ne 1 ]
#then
#    echo "useage: stat_data_source data_filename";
#    exit 1;
#fi;
#
#data=$1;
echo ${data}


perl -lne '{
	if ($_ =~ /\/\/(.*?)\/.+?\/\/(.*?)\//) { 
		@F = split(/\./, $2);
		print $F[@F-2].".".$F[@F-1]."\t".$_;
	}
}' ${data} > ${temp}.objs_info

awk -F '\t' -v type_sum="${temp}.type_sum" -v dx_amount="${dingxiang_amount}" '{
    if(FILENAME==ARGV[1]){
		count[$1] = 0;
	} else if(FILENAME==ARGV[2]){
        used_objs[$1]=1;
    } else if(! ($2 in used_objs)){    
        count[$NF]+=1;
		total++;
		key = $1"-"$NF;
		domain_type[key]++;
    } else if ($2 in used_objs) {
		#print $0 > "used_out";
		used++;
	}
}END{
	for(type in count){
		#print type"\t"count[type]"\t"count[type]/total"\t"(int)(count[type]*dx_amount/total) > type_sum;
		printf("%s\t%d\t%f\t%d\n", type, count[type], count[type]/total, count[type]*dx_amount/total) > type_sum;
		demand[type] = count[type]*dx_amount/total;
    }

	for (key in domain_type) {
		print key"\t"domain_type[key]| "sort -n -r -k1";
	}
	print "Total="total"\tUsed="used;
}' ${type_index} ${used_objs} ${temp}.objs_info


#awk -F'\t' '{
#   print $2;
#}' ${data}  | perl -lne '{ 
#	if ($_ =~ /\/\/(.*?)\//) { 
#		print $1; 
#	}
#}'	| awk -F'\t' '{
#   if (!mark[$0]) {
#       print $0;
#       mark[$0] = 1;
#   }
#}' > ${site_out}


