#!/bin/bash

filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
dingxiang="./data/swap/dingxiang_final_objs_data.without_path"
mine="./data/swap/mine_final_objs_data.without_path"
out_404=${temp}".black_obj_404"

echo "Begin.."

awk -F '\t'  '{
	if (index($2, "fengniao.com")) {
		print $1;
	}
}' ${dingxiang} ${mine}  > ${out_404}

echo "Finished."
