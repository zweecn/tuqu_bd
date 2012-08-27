#!/bin/bash

d1="data/swap/mine_final_objs_data.without_path"
d2="data/swap/dingxiang_final_objs_data.without_path" 
d3="../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data.without_path"
d4="../tuqu_baidu_other4/data/swap/mine_final_objs_data.without_path"

awk -F '\t' '{
	if (!mark[$1]) {
		print;
		mark[$1] = 1;
	}
}' $d1 $d2 $d3 $d4 > data/swap/all_pass_data 
