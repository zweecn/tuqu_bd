#!/bin/bash

swap="./data/swap"
input="./data/input"

all_files=`ls ${input}/objs_local_path*` 
out=${swap}"/local_path.merge"

for map_file in ${all_files[@]}
do
	echo ${map_file}
	awk -F '\t' '{
		if (!mark[$0]) {
			print;
			mark[$0] = 1;
		}
	}' ${map_file} > ${out}
done
