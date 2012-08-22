#!/bin/bash


#input="./data/merged"
input="./data/tag_parser.out";
temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`

data_without_thumb="./data/output.mg_black_list"
output="./data/output.thumb"

## 1. get thumb
awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		thumb_url[$1] = "http://t"(($7 + $8) %3 + 1)".baidu.com/it/u="$7","$8"&fm=52&gp=0.jpg";
		from_url[$1] = $2;
	}
	else
	{
		print $0"\t"thumb_url[$2]"\t"from_url[$2];
	}
}' ${input} ${data_without_thumb} > ${temp}.out
if [ ${?} -ne 0 ]
then
	echo "add thumb failed!"
	exit 1
fi

## 2. output
rm -rf ${output}.bak
mv ${output} ${output}.bak
cp ${temp}.out ${output}

exit 0

