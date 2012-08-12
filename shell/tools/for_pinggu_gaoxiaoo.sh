#!/bin/bash
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/tmp/"${filename}

gaoxiaoo="data/input/gaoxiaoo_idsoo_kaixin001_laifu_taitaitang.out"
output_dir="./data/tmp/pinggu"
black_obj="./conf/obj_black_list"

#rm -rf ${output_dir}
#mkdir -p ${output_dir}
#
#echo "Begin generate the tags file for pingu..."
#
#awk -F '\t' '{
#	if (!mark[$1]) {
#		gsub("��", "$$", $4);
#		gsub("\\/", "$$", $4);
#		gsub(",", "$$", $4);
#		gsub("��", "$$", $4);
#		gsub("��", "$$", $4);
#		gsub("��", "$$", $4);
#		gsub("\\?", "$$", $4);
#		gsub("��", "$$", $4);
#		gsub("-", "$$", $4);
#		gsub(" ", "$$", $4);
#		gsub("\\.", "$$", $4);
#		gsub("\\~", "$$", $4);
#		gsub("��", "$$", $4);
#		gsub("\\*", "$$", $4);
#		gsub("\\`", "$$", $4);
#
#		gsub("\\/", "$$", $3);
#		gsub(",", "$$", $3);
#		gsub("��", "$$", $3);
#		gsub("��", "$$", $3);
#		gsub("��", "$$", $3);
#		gsub("\\?", "$$", $3);
#		gsub("��", "$$", $3);
#		gsub("-", "$$", $3);
#		gsub(" ", "$$", $3);
#		gsub("\\.", "$$", $3);
#		gsub("\\~", "$$", $3);
#		gsub("��", "$$", $3);
#		gsub("��", "$$", $3);
#		gsub("\\*", "$$", $3);
#		gsub("\\`", "$$", $3);
#		
#		add_tag = "";
#		if (index($2, "gaoxiaoo") || index($2, "kaixin001") || index($2, "laifu")) {
#			add_tag = "Ȥζ��Ц";	
#		} else if (index($2, "idsoo") || index($2, "taitaitang")) {
#			add_tag = "�Ҿ�װ��";
#		}
#		if ($4 != "") {
#			print $1 "\t" $2 "\t" $4 "$$" add_tag;
#		} else if (length($3) < 20){
#			print $1 "\t" $2 "\t" $3 "$$" add_tag;
#		}
#
#		mark[$1] = 1;
#	}
#}' ${gaoxiaoo} > ${temp}.gaoxiaoo
#
#echo -e "ȥ�غ���ļ������ ${temp}.gaoxiaoo �� `wc -l ${temp}.gaoxiaoo |cut -d' ' -f 1` �� "
#
#awk -F '\t' '{
#	delete tags;
#	split($3, tags, "\\$\\$");
#	for (i in tags) {
#		tag = tags[i];
#		if (tags[i] == "") {
#			continue;
#		}
#		cnt[tag]++;
#		if (index($2, "idsoo") || index($2, "taitaitang")) {
#			jiaju_types[tag]++;
#		} 
#		if (index($2, "gaoxiaoo") || index($2, "kaixin001") || index($2, "laifu")) {
#			gaoxiao_types[tag]++;	
#		}
#	}
#
#} END {
#	for (tag in cnt) {
#		print tag"\t"cnt[tag]"\t"(gaoxiao_types[tag] > jiaju_types[tag] ? "Ȥζ��Ц" : "�Ҿ�װ��");
#	}
#}' ${temp}.gaoxiaoo | sort -n -r -k2 > ${temp}.tag_cnt 
#
#echo "tag ��Ƶ���ֵ��ļ������ " ${temp}.tag_cnt
#
#awk -F '\t' -v out="${output_dir}" '{
#	if (FILENAME == ARGV[1]) {
#		at[$1] = $2;	
#	} else {
#		delete tags;
#		split($3, tags, "\\$\\$");
#		if ($3 == "")
#			print ;
#		cnt++;
#		for (i in tags) {
#			if (tags[i] == "") {
#				continue;
#			}
#			if (!(tags[i] in at)) {
#				continue;
#			}
#			if ($1 != "") {
#				print $1"\t"$1"\t"$2"\t"1 > out"/"tags[i]".txt";
#			}
#		}
#	}
#} END {
#	print "Total:" cnt;
#}' ${temp}.tag_cnt ${temp}.gaoxiaoo
#
#echo -e "��Ҫ������tag����� ${output_dir}"
#
#echo "Finish generated."
#
#

all_files=`ls data/tmp/pinggu/`
for file in ${all_files[@]}
do
	awk -F '\t' '{
		if (!mark[$1] && index($1, "http")) {
			mark[$1] = 1;
			print $1;
		}
	}' data/tmp/pinggu/${file} > data/tmp/gaoxiaoo.uniq
done


