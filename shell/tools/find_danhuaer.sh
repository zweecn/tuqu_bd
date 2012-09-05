#!/bin/bash

awk -F '\t' '{
	if (!mark[$1] && index($3, "danhuaer.com") && index($2, "·ç¾°") && index($2, "·þÊÎ´îÅä")) {
		print;
		mark[$1] = 1;
	}
}' data/swap/dingxiang_final_objs_data  ../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data > data/temp/danhuaer_fengjing

awk -F '\t' '{
	if (!mark[$1] && index($3, "danhuaer.com")) {
		print;
		mark[$1] = 1;
	}
}' data/swap/dingxiang_final_objs_data  ../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data > data/temp/danhuaer

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		black[$1] = 1;
	} else {
		if ($1 in black)
			next;
		print;
	}
}' data/temp/danhuaer data/swap/dingxiang_final_objs_data > data/swap/dingxiang_final_objs_data.without_danhuaer 

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		black[$1] = 1;
	} else {
		if ($1 in black)
			next;
		print;
	}
}' data/temp/danhuaer ../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data > ../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data.without_danhuaer 

mv data/swap/dingxiang_final_objs_data data/swap/dingxiang_final_objs_data.with_danhuaer
mv data/swap/dingxiang_final_objs_data.without_danhuaer data/swap/dingxiang_final_objs_data
mv ../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data ../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data.with_danhuaer
mv ../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data.without_danhuaer ../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data
