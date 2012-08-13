#!/bin/bash

objs_path="data/input/objs_local_path_zw.20120812"
out="data/swap/objs"

rm ${out}*

while read line
do
	file=`echo ${line} | cut -d' ' -f1 `
	res=`file ${file} | perl -lne '{if ($_ =~ /(image)/) { print "YES";} else {print "NO";}}'`
	echo ${file} ${res}
	if [ ${res} = "YES" ]; then
		echo ${file} >> ${out}.exist
	else
		echo ${file} >> ${out}.not_exist
	fi
done < ${objs_path} 
