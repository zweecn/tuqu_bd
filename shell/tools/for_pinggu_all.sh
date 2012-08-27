#!/bin/bash
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/tmp/"${filename}

objs_all="data/input/objs_all"

#d1="data/swap/dingxiang_final_objs_data.without_path"
#d2="data/swap/mine_final_objs_data.without_path"
#d3="../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data.without_path"
#d4="../tuqu_baidu_other4/data/swap/mine_final_objs_data.without_path"

d1="data/swap/dingxiang_final_objs_data"
d2="data/swap/mine_final_objs_data"
d3="../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data"
d4="../tuqu_baidu_other4/data/swap/mine_final_objs_data"


dingxiang_all="data/temp/dingxiang_all_pinggu"
mine_all="data/temp/mine_all_pinggu"
do1="data/temp/dingxiang_mine_all_pinggu"

tag_cnt="data/temp/all_tag_cnt"

output_dir="./data/tmp/pinggu"
black_obj="./conf/obj_black_list"

echo "Begin generate the tags file for pingu..."
rm -rf ${output_dir}
mkdir -p ${output_dir}

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		desc[$8] = $4; 
#	} else {
#		if (!mark[$1]) {
#   			gsub(",", "$$", $2);
#			split($NF, arr, "-");
#			print $1 "\t" $1 "\t" $3 "\t" 1 "\t" $2 "\t" desc[$1] "\t" arr[2];
#			mark[$1] = 1;
#		}
#	}
#}' ${objs_all} $d1 $d3 > $dingxiang_all

awk -F '\t' '{
	if (!mark[$1]) {
   		gsub(",", "$$", $2);
		print $1 "\t" $1 "\t" $3 "\t" 1 "\t" $2 "\t" "\t" $NF;
		mark[$1] = 1;
	}
}' $d2 $d4 > $mine_all

awk -F '\t' '{
	if (!mark[$1]) {
		print;
		mark[$1] = 1;
	} 
}' $dingxiang_all $mine_all > $do1


echo "Begin output tags.txt..."
awk -F '\t' -v out="${output_dir}" '{
	if (FILENAME == ARGV[1]) {
		types[$1] = $2;
	} else if (FILENAME == ARGV[2]) {
		type_index[$2] = $1;	
	} else {
		delete tags;
		split($5, tags, "\\$\\$");
		cnt++;
		for (i in tags) {
			if (tags[i] == "") {
				continue;
			}
			if ($1 != "") {
				print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6> out "/" tags[i] ".txt";
				tag_cnt[tags[i]] ++;
			}
		}
	}
} END {
	for (tag in tag_cnt) {
		print tag "\t" tag_cnt[tag] "\t" type_index[types[tag]];	
	}
}' conf/all_tag_list conf/all_type_index $do1 | sort -k2 -n -r >  $tag_cnt

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


