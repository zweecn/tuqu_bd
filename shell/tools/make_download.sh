#!/bin/bash

filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
today=`date +%Y%m%d`

#d1="./data/temp/pre_online.mine.urls_to_download"
#d2="./data/temp/pre_online.dingxiang.urls_to_download"
d1="data/download_info/5before.dingxiang.urls_to_download.20120808"
d2="data/download_info/5before.mine.urls_to_download.20120808"
d3="../tuqu_baidu_other4/data/download_info/other4.mine.urls_to_download.20120808"

out="data/download_info/total_urls_to_download."${today}

black_obj="conf/obj_black_list"


echo "Begin..."
awk -F'\t' '{
	if (FILENAME == ARGV[1]) {
		black[$1] = 1;
	}
	if (!mark[$1] && !($1 in black)) {
		print $1;
		mark[$1] = 1;
	}
}' ${black_obj} ${d1} ${d2} ${d3} | awk -F '\t' '{
	print $1"\t"rand();
}' | sort -n -k2 | awk -F '\t' '{print $1;}' > ${out}

echo "Finished."
