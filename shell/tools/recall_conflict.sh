#!/bin/bash

dingxiang="data/temp/pre_online.dingxiang.type_conflict"
dingxiang_out="data/temp/pre_online.dingxiang.type_conflict.recall"

awk -F '\t' '{
	print $0"\t"rand(); 
}' ${dingxiang} | sort -n -k6 | awk -F '\t' '{
	print $1"\t"$2"\t"$3"\t"$4"\t"$5;
}' | head -n 100 > ${dingxiang}.rand100 
