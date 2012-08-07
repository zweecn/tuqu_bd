#!/bin/bash
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
#no_type_input="./data/temp/produce_data_control.dingxiang.no_type"
no_type_input="./data/temp/pre_online.dingxiang.no_type"
output_dir="./data/temp/pinggu"
black_obj="./conf/obj_black_list"
already_pinggu="./conf/already_pingu"

rm -rf ${output_dir}
mkdir -p ${output_dir}

echo "Begin generate the tags file for pingu..."

awk -F '\t' '{
	gsub(/\//, ",", $3);
	gsub(/\./, "", $3);
	split($3, tags, ",");
	for (i in tags) {
		if (tags[i] == "") {
			continue;
		}
		cnt[tags[i]]++;
	} 

} END {
	for (tag in cnt) {
		if (cnt[tag] >= 200) {
			print tag"\t"cnt[tag];
		}
	}
}' ${no_type_input} > ${temp}.tag_cnt 

awk -F '\t' -v out="${output_dir}" '{
#	print $1"\t"$1"\t"$2"\t"1;
	if (FILENAME == ARGV[1]) {
		at[$1] = 1;	
	} else if (FILENAME == ARGV[2]) {
		black_obj[$1] = 1;
	} else if (FILENAME == ARGV[3]) {
		already[$1] = 1;
	} else {
		gsub(/\//, ",", $3);
		gsub(/\./, "", $3);
		split($3, tags, ",");
		for (i in tags) {
			if (tags[i] == "") {
				continue;
			}
			if (tags[i] in already) {
				next;
			}
			if (!(tags[i] in at)) {
				continue;
			}
			if ($1 in black_obj) {
				continue;
			}
			if (index($2, "fengniao.com")) {
				next;
			}
			if ($1 != "") {
				print $1"\t"$1"\t"$2"\t"1 > out"/"tags[i]".txt";
			}
		}
	}
}' ${temp}.tag_cnt ${black_obj} ${already_pinggu} ${no_type_input}

all_tag_file=`ls ${output_dir}`
cat ${output_dir}/* > ${temp}.all_pinggu

awk -F '\t' '{
	if (!mark[$1]) {
		mark[$1] = 1;
		print;
	}
} END {
}' ${temp}.all_pinggu > ${temp}.all_pinggu.uniq	

echo -e "一共 输出到 ${temp}.all_pinggu.uniq 文件，共 `wc -l ${temp}.all_pinggu.uniq | cut -d ' ' -f 1` 条"
echo -e "需要评估的tag输出到 ${output_dir}"

echo "Finish generated."


#input="./data/output.thumb"
#output_dir="./data/pinggu"


#rm -rf ${output_dir}
#mkdir -p ${output_dir}

#awk -F'	' '{
#	str = $3"$$"$4;
#	gsub(/\//, "", str);
#	out_str = $2"\t"$5"\t"$6;
#	n = split(str, a, "\\$\\$");
#	delete b;
#	for(i in a)
#	{
#		if(a[i] == "")
#		{
#			continue;
#		}
#		if(!(a[i] in b))
#		{
#			cnt[a[i]]++;
#			b[a[i]] = 1;
#		}
#	}
#} END {
#	for(i in cnt)
#	{
#		print i"\t"cnt[i];
#	}
#}' ${input} > o
#

#awk -F'	' '{
#	if(FILENAME == ARGV[1])
#	{
#		if($2 > 100)
#		{
#			at[$1] = 1;
#		}
#	} 
#	else
#	{
#		str = $3"$$"$4;
#		gsub(/\//, "", str);
##		out_str = $2"\t"$5"\t"$6"\t"1;
#		out_str = $2"\t"$2"\t"$6"\t"1;
#		n = split(str, a, "\\$\\$");
#		delete b;
#		for(i in a)
#		{
#			if(a[i] == "")
#			{
#				continue;
#			}
#			if(!(a[i] in at))
#			{
#				continue;
#			}
#			if(!(a[i] in b))
#			{
#				print out_str > "'${output_dir}'/"a[i]".txt";
#				b[a[i]] = 1;
#			}
#		}
#}
#} END {
#	print cnt;
#}' o ${input}
#if [ ${?} -ne 0 ]
#then
#	echo "for pinggu failed!"
#	exit 1
#fi
#
#scp ${output_dir}/* img@tc-apptest-img09.vm:/home/img/lighttpd_8088/htdocs/objInfoByTag/      
