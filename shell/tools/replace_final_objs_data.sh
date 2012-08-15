#!/bin/bash

d_objs="data/swap/dingxiang_final_objs_data"
m_objs="data/swap/mine_final_objs_data"

d_out="v3/data/swap/dingxiang_final_objs_data"
m_out="v3/data/swap/mine_final_objs_data"

awk -F'\t' '{
	split($4, arr, "res");
	print $1"\t"$2"\t"$3"\t/home/img/tuqu_data/data/res"arr[2]"\t"$5"\t"$6;
}' ${d_objs} > ${d_out}

awk -F'\t' '{
	split($4, arr, "res");
	print $1"\t"$2"\t"$3"\t/home/img/tuqu_data/data/res"arr[2]"\t"$5"\t"$6;
}' ${m_objs} > ${m_out}

echo "Finished."
