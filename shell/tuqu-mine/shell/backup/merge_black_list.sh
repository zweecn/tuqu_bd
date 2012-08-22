#!/bin/bash


black_list="./conf/black_list"
temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
input="./data/output.merge_pm_tag"

output="./data/output.mg_black_list"


awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = 1;
	}
	else
	{
		if($1 in a)
		{
			next;
		}
		print;
	}
}' ${black_list} ${input} > ${temp}.out
if [ ${?} -ne 0 ]
then
	echo "rm black list failed!"
	exit 1
fi

## output
rm -rf ${output}.bak
mv ${output} ${output}.bak
cp ${temp}.out ${output}

exit 0
