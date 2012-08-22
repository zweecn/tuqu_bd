#!/bin/bash

input="./data/output.thumb"
output_dir="./data/pinggu"


rm -rf ${output_dir}
mkdir -p ${output_dir}

#awk -F'	' '{
#	str = $3"$$"$4;
#	gsub(/\//, "", str);
#	out_str = $2"\t"$5"\t"$6;
#	n = split(str, a, "\\$\\$");
#	delete b;
#	for(i in a)
#	{
#		if(a[i] == "")
#		{
#			continue;
#		}
#		if(!(a[i] in b))
#		{
#			cnt[a[i]]++;
#			b[a[i]] = 1;
#		}
#	}
#} END {
#	for(i in cnt)
#	{
#		print i"\t"cnt[i];
#	}
#}' ${input} > o
#

awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		if($2 > 100)
		{
			at[$1] = 1;
		}
	} 
	else
	{
		str = $3"$$"$4;
		gsub(/\//, "", str);
#		out_str = $2"\t"$5"\t"$6"\t"1;
		out_str = $2"\t"$2"\t"$6"\t"1;
		n = split(str, a, "\\$\\$");
		delete b;
		for(i in a)
		{
			if(a[i] == "")
			{
				continue;
			}
			if(!(a[i] in at))
			{
				continue;
			}
			if(!(a[i] in b))
			{
				print out_str > "'${output_dir}'/"a[i]".txt";
				b[a[i]] = 1;
			}
		}
}
} END {
	print cnt;
}' o ${input}
if [ ${?} -ne 0 ]
then
	echo "for pinggu failed!"
	exit 1
fi

scp ${output_dir}/* img@tc-apptest-img09.vm:/home/img/lighttpd_8088/htdocs/objInfoByTag/      
