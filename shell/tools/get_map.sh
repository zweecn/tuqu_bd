#!/bin/bash

md5_map="data/img09/name_map_md5"
md5_map_tmp="data/img09/name_map_md5_tmp"
objs_map="data/img09/objs_map"

awk -F ' ' '{
	print $1 "\t" $2 "\t" $3;
}' $md5_map > $md5_map_tmp


awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		split($1, arr, "client");
		key = "data" arr[2];
		f[key] = $1;
		o[key] = $2;
	} else {
		print f[$1] "\t" o[$1] "\t" $2 "\t" $3;		
	}
}' data/input/objs_local_path $md5_map_tmp > $objs_map

echo "Finished."
