#!/bin/bash

awk -F '\t' '{
	if (index($0, "��Ц") || index($NF, "�羰")) {
		print $0;
	}
}' data/swap/dingxiang_final_objs_data.without_path
