#!/bin/bash

all_out="data/img09/all_pinggu_local"
all_format="data/img09/all_pinggu_local.format"

#echo "Format all_out..."
#awk -F '\t' '{
#	n = split($2, arr, "res");
#	if (n == 1) {
#		delete arr;
#		split($2, arr, "data");
#		local = "data/res" arr[2]; 
#		print $1 "\t" local "\t" $3 "\t" $4 "\t" $5 "\t" $6;
#	} else {
#		print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6;
#	}
#}' $all_out > $all_format

echo "Make local path..."
tag_1_dir="data/img09/objInfoByTag.online"
tag_2_dir="data/img09/objInfoByTag.local"
#rm -rf $tag_2_dir
#mkdir -p $tag_2_dir
#while read tag
#do
#	tag_1_path="${tag_1_dir}/${tag}.txt"
#	tag_2_path="${tag_2_dir}/${tag}.txt"
#	echo $tag_1_path "-->" $tag_2_path
#	
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			objs[$1] = $2;
#		} else {
#			if ($1 in objs) {
#				print $1 "\t" objs[$1] "\t" $3 "\t" $4 "\t" $5 "\t" $6;	
#			}
#		}
#	}' $all_format $tag_1_path > $tag_2_path
#
#done < data/temp/pm_tags_other

echo "Do already pinggu tags..."
while read tag
do
	tag_1_path="${tag_1_dir}/${tag}.txt"
	tag_2_path="${tag_2_dir}/${tag}_new.txt"
	echo $tag_1_path "-->" $tag_2_path
	
	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			objs[$1] = $2;
		} else {
			if ($1 in objs) {
				print $1 "\t" objs[$1] "\t" $3 "\t" $4 "\t" $5 "\t" $6;	
			}
		}
	}' $all_format $tag_1_path > $tag_2_path
#scp $tag_2_path img@tc-apptest-img09.vm.baidu.com:/home/img/lighttpd_8088/htdocs/objInfoByTag 
done < data/temp/already_pinggu_tags

#echo "Do already pinggu death tags..."
#while read tag
#do
#	tag_1_path="${tag_1_dir}/${tag}.txt"
#	tag_2_path="${tag_2_dir}/${tag}_death.txt"
#	echo $tag_1_path "-->" $tag_2_path
#	
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			objs[$1] = $2;
#		} else if (FILENAME == ARGV[2]) {
#			death[$1] = 1;
#		}else {
#			if ($1 in objs) {
#				is_death = 0;
#				for (site in death) {
#					if (index($0, site)) {
#						is_death = 1;	
#						break;
#					}
#				}
#				if (is_death)
#					print $1 "\t" objs[$1] "\t" $3 "\t" $4 "\t" $5 "\t" $6;	
#			}
#		}
#	}' $all_format conf/death_site $tag_1_path > $tag_2_path
#	scp $tag_2_path img@tc-apptest-img09.vm.baidu.com:/home/img/lighttpd_8088/htdocs/objInfoByTag 
#done < data/temp/already_pinggu_tags

#while read tag
#do
#	path="${tag_1_dir}/${tag}.txt" 
#	path_1="${tag_1_dir}/${tag}_1.txt" 
#	path_2="${tag_1_dir}/${tag}_2.txt" 
#	path_new="${tag_1_dir}/${tag}_new.txt" 
#	path_death="${tag_1_dir}/${tag}_death.txt" 
#	zero_path=`awk -F '\t' '{
#		if ($4 == 0) {
#			print;
#		}
#	}' $path | wc -l`	
#	zero_path_1=`awk -F '\t' '{
#		if ($4 == 0) {
#			print;
#		}
#	}' $path_1 | wc -l`	
#	zero_path_2=`awk -F '\t' '{
#		if ($4 == 0) {
#			print;
#		}
#	}' $path_2 | wc -l`	
#
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			if ($4 == 0)
#				obj_res[$1] = 0;
#		} else {
#			if ($1 in obj_res)
#				print $1 "\t" $2 "\t" $3 "\t" 0 "\t" $5 "\t" $6;
#			else
#				print;
#		}
#	}' $path_2 $path_1 > $path_new 
#
#	zero_path_new=`awk -F '\t' '{
#		if ($4 == 0) {
#			print;
#		}
#	}' $path_new | wc -l`	
#
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			death[$1] = 1;
#		}else {
#			is_death = 0;
#			for (site in death) {
#				if (index($0, site)) {
#					is_death = 1;	
#					break;
#				}
#			}
#			if (is_death)
#				print;
#		}
#	}' conf/death_site $path_1 > $path_death
#	
#	scp $path_death img@tc-apptest-img09.vm.baidu.com:/home/img/lighttpd_8088/htdocs/objInfoByTag
#	echo $tag $zero_path $zero_path_1 $zero_path_2 $zero_path_new
#done < data/temp/tag_conflict

#rm -rf $all_200
#while read line 
#do
#	from=`echo $line | awk -F ' ' '{print $3;}'`
#	echo $from
#	wget --spider $from
#	if [ $? -ne 0 ]; then
#		continue
#	fi
#	echo $line | awk -F ' ' '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}' >> $all_200
#done < $all


echo "Finished."
