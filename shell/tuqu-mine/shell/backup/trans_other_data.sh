#!/bin/bash

input="./data/objs_all"
temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
output_dir="./data/pinggu1"

#awk -F'	' '{
#	if($13 && !a[$8])
#	{
#		gsub("&&", "$$", $13);
#		print $8"\t"$9"\t"$13;
#		a[$8] = 1;
#	}
#}' ${input} > ${temp}.uf
#
rm -rf ${output_dir}
mkdir ${output_dir}

awk -F'	' '{
	str = $3;
	gsub(/\//, "", str);
	out_str = $1"\t"$1"\t"$2"\t"1;
	n = split(str, a, "\\$\\$");
	delete b;
	for(i in a)
	{
		gsub(/^[ ]+|[ ]$/, "", a[i]);
		if(a[i] == "")
		{
			continue;
		}
#		if(!(a[i] in at))
#		{
#			continue;
#		}
		if(!(a[i] in b))
		{
			print out_str > "'${output_dir}'/"a[i]".txt";
			b[a[i]] = 1;
		}
	}
	
}' ${temp}.uf
if [ ${?} -ne 0 ]
then
	echo "for pinggu failed!"
	exit 1
fi


scp -r ${output_dir}/* img@tc-apptest-img09.vm:/home/img/lighttpd_8088/htdocs/objInfoByTag1
