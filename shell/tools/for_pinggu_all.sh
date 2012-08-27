#!/bin/bash
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/tmp/"${filename}

objs_all="data/input/objs_all"

d1="data/swap/dingxiang_final_objs_data.without_path"
d2="data/swap/mine_final_objs_data.without_path"
d3="../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data.without_path"
d4="../tuqu_baidu_other4/data/swap/mine_final_objs_data.without_path"

dingxiang_all="data/temp/dingxiang_all_pinggu"
mine_all="data/temp/mine_all_pinggu"
do1="data/temp/dingxiang_mine_all_pinggu"

output_dir="./data/tmp/pinggu"
black_obj="./conf/obj_black_list"

rm -rf ${output_dir}
mkdir -p ${output_dir}

echo "Begin generate the tags file for pingu..."

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		desc[$8] = $4; 
#	} else {
#		if (!mark[$1]) {
#   			gsub(",", "$$", $3);
#			print $1 "\t" $1 "\t" $2 "\t" 1 "\t" $3 "\t" desc[$1] ;
#			mark[$1] = 1;
#		}
#	}
#}' ${objs_all} $d1 $d3 > $dingxiang_all
#
#awk -F '\t' '{
#	if (!mark[$1]) {
#   		gsub(",", "$$", $3);
#		print $1 "\t" $1 "\t" $2 "\t" 1 "\t" $3 "\t";
#		mark[$1] = 1;
#	}
#}' $d2 $d4 > $mine_all
#
#awk -F '\t' '{
#	if (!mark[$1]) {
#		print;
#		mark[$1] = 1;
#	} 
#}' $dingxiang_all $mine_all > $do1

awk -F '\t' -v out="${output_dir}" '{
	delete tags;
	split($5, tags, "\\$\\$");
	cnt++;
	for (i in tags) {
		if (tags[i] == "") {
			continue;
		}
		if ($1 != "") {
			print $0 > out "/" tags[i] ".txt"
		}
	}
} END {
	print "Total:" cnt;
}' $do1 

echo -e "需要评估的tag输出到 ${output_dir}"

echo "Finish generated."



#all_files=`ls data/tmp/pinggu/`
#for file in ${all_files[@]}
#do
#	awk -F '\t' '{
#		if (!mark[$1] && index($1, "http")) {
#			mark[$1] = 1;
#			print $1;
#		}
#	}' data/tmp/pinggu/${file} > data/tmp/gaoxiaoo.uniq
#done
#

