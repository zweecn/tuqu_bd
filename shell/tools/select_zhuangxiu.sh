#!/bin/bash

tag_file="data/tmp/zhuangxiu.txt"
objs_local="data/input/objs_local_path"

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		local_path[$2] = $1;
#	} else {
#		print local_path[$1];
#	}
#}' $objs_local $tag_file > data/tmp/local_pics 

while read line
do
	dir="data/"`echo $line | awk -F '\t' '{
		split($1, arr, "client");
		print arr[2];
	}' | awk -F '/' '{
		print $2 "/" $3 "/" $4;
	}'`
	old_name="data"`echo $line | awk -F '\t' '{
		split($1, arr, "client");
		print arr[2];
	}'`
	
	mkdir -p $dir
	remote="img@jx-apptest-img04.vm.baidu.com:${line}"
	echo -e "scp $remote $dir"
	scp $remote $dir

	new_name=`echo $old_name | awk -F '.' '{print $1 ".";}'``file $old_name | cut -d' ' -f2 | awk '{print tolower($0);}'`
	echo $new_name
	mv $old_name $new_name
	
	break;
done < data/tmp/local_pics

