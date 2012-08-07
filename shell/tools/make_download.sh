#!/bin/bash

filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
today=`date +%Y%m%d`

d1="./data/temp/pre_online.mine.urls_to_download"
d2="./data/temp/pre_online.dingxiang.urls_to_download"
out=${temp}".urls_to_download."${today}

echo "Begin..."
awk -F'\t' '{
	if (!mark[$1]) {
		print $1;
		mark[$1] = 1;
	}
}' ${d1} ${d2} > ${out}

echo "Finished."
