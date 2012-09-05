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
do2="data/temp/dingxiang_mine_all_pinggu_local"

tag_cnt="data/temp/all_tag_cnt"

output_dir="./data/tmp/pinggu"
black_obj="./conf/obj_black_list"

date

#echo "Begin generate the tags file for pingu..."
#
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
#
#awk -F '\t' '{
#	if (!mark[$1]) {
#   		gsub(",", "$$", $2);
#		print $1 "\t" $1 "\t" $3 "\t" 1 "\t" $2 "\t" "\t" $NF;
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
#
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		obj_local[$2] = $1;
#	} else {
#		print obj_local[$1] "\t" $1;
#	}
#}' data/input/objs_local_path $do1 > data/img09/all_pics

#rm -rf data/img09/name_map
#rm -rf data/img09/not_pic
#while read line obj
#do
#	echo $line
#	dir="data/"`echo $line | awk -F '\t' '{
#		split($1, arr, "client");
#		print arr[2];
#	}' | awk -F '/' '{
#		print $2 "/" $3 "/" $4;
#	}'`
#	old_name="data"`echo $line | awk -F '\t' '{
#		split($1, arr, "client");
#		print arr[2];
#	}'`
#	
#	mkdir -p $dir
#	remote="img@jx-apptest-img04.vm.baidu.com:${line}"
#	scp $remote $dir
#	
#	ex=`file $old_name | cut -d' ' -f2 | awk '{print tolower($0);}'`
#	flag=`echo $ex | awk '{if ($1 != "jpg" && $1 != "jpeg" && $1 != "png" && $1 != "gif") print 0; else print 1;}'`
#	if [ $flag -ne 1 ]; then
#		rm -rf $old_name
#		echo -e "$old_name" >> data/img09/not_pic
#		continue
#	fi
#	new_name=`echo $old_name | awk -F '.' '{print $1 ".";}'`$ex
#	mv $old_name $new_name
#	echo -e "${obj}\t${line}\t${new_name}\t`md5sum $new_name | cut -d' ' -f1`" >> data/img09/name_map
#done < data/img09/all_pics

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		obj_local[$1] = $3;	
#	} else {
#		if ($1 in obj_local)
#			print $1 "\t" obj_local[$1] "\t" $3 "\t" $4 "\t" $5 "\t" $6;
#	}
#}' data/img09/name_map $do1 > $do2

#echo "Begin output tags.txt..."
#rm -rf ${output_dir}
#mkdir -p ${output_dir}
#awk -F '\t' -v out="${output_dir}" '{
#	if (FILENAME == ARGV[1]) {
#		types[$1] = $2;
#	} else if (FILENAME == ARGV[2]) {
#		type_index[$2] = $1;	
#	} else {
#		delete tags;
#		split($5, tags, "\\$\\$");
#		cnt++;
#		for (i in tags) {
#			if (tags[i] == "") {
#				continue;
#			}
#			if ($1 != "") {
#				print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 > out "/" tags[i] ".txt";
#				tag_cnt[tags[i]] ++;
#			}
#		}
#	}
#} END {
#	for (tag in tag_cnt) {
#		print tag "\t" tag_cnt[tag] "\t" type_index[types[tag]];	
#	}
#}' conf/all_tag_list conf/all_type_index $do1 | sort -k2 -n -r >  $tag_cnt
#
#echo -e "需要评估的tag输出到 ${output_dir}"

#pm_tags="data/temp/pm_tags_other"
#pm_tags_out="data/temp/pm_tags_other.out"
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		tag_cnt[$1] = $2;
#		type[$1] = $3;
#	} else {
#		print $1 "\t" tag_cnt[$1] "\t" type[$1];
#	}
#}' $tag_cnt $pm_tags > $pm_tags_out

#echo "Begin scp to img09..."
#scp -p -r data/res img@tc-apptest-img09.vm.baidu.com:/home/img/lighttpd_8088/htdocs/data2

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

date

