#!/bin/bash

tag_file="data/tmp/zhuangxiu.txt"
objs_local="data/input/objs_local_path"

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		local_path[$2] = $1;
	} else {
		split(local_path[$1], arr, "client");
		split(arr[2], jpg, "\\.");
		path = "data" jpg[1] ".jpg"; 
		print $1 "\t" path "\t" $3 "\t" $4 "\t" $5 "\t" $6;
	}
}' $objs_local $tag_file > data/tmp/zhuangxiu.new.txt 

