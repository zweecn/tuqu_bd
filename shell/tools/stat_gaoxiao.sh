#!/bin/bash

awk -F '\t' '{
	if (index($0, "¸ãÐ¦") || index($NF, "·ç¾°")) {
		print $0;
	}
}' data/swap/dingxiang_final_objs_data.without_path
