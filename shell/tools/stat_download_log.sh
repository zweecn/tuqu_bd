#!/bin/bash

rec_log="data/download_info/receive.log"
d1="data/swap/dingxiang_final_objs_data.without_path"
d2="data/swap/mine_final_objs_data.without_path"
out="data/download_info/log"

echo "开始统计..."
awk -F ' ' -v out="${out}" '{
	if (FILENAME == ARGV[1]) {
		dingxiang[$1] = 1;
	} else if (FILENAME == ARGV[2]) { 
		mine[$1] = 1;
	} else {
		if ($9 == "" || $10 == "") {
			next;
		}
		if ($10 in dingxiang) {
			o1 = out"/dingxiang_"$9;
			print $10 > o1;
		} else if ($10 in mine) {
			o1 = out"/mine_"$9;
			print $10 > o1;
		}
	}
}' ${d1} ${d2} ${rec_log} 
echo "统计完成"
