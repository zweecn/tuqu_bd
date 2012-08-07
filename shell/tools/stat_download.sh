#!/bin/bash

# 统计已经下载的数据情况

filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
today=`date +%Y%m%d`

d1="data/swap/dingxiang_final_objs_data.without_path"
d2="data/swap/mine_final_objs_data.without_path"

succ="data/download_info/objs_local_path_zw.uniq"
failed="data/download_info/objs_local_path_zw.download.failed.uniq"
not_img="data/download_info/objs_local_path_zw.non.img.uniq"

cat ${d1} ${d2} > ${temp}.all

awk -F '\t' -v download="${temp}.download" '{
	if (FILENAME == ARGV[1]) {
		s[$2] = 1;	
	} else {
		if ($1 in s) {
			print $0 > download;
		} else {
			print $0;
		}
	}

}' ${succ} ${temp}.all > ${temp}.not_download  

awk -F '\t' -v failed_info="${temp}.failed" -v no_img_info=""${temp}.no_img '{
	if (FILENAME == ARGV[1]) {
		failed[$2] = 1;
	} else if (FILENAME == ARGV[2]) {
		not_img[$2] = 1;
	} else {
		if ($1 in failed) {
			print $0  > failed_info;
		} else if ($1 in not_img) {
			print $0 > no_img_info;
		}
	}

}' ${failed} ${not_img} ${temp}.not_download  



echo Finished.
