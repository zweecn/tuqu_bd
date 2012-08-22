#!/bin/bash

input="./data/source_valid.rm_useless"
temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
tag_list="./data/tag_list"
person_name="./conf/person"
area_tag="./conf/area_tag"
area="./conf/area"
humor_tag="./conf/humor_tag"

output="./data/output"

awk -F'	' 'BEGIN { OFS = "\t"; }
{
	if(FILENAME == ARGV[1])
	{
		if(length($1) <= 2 || $1 ~ /^[0-9]+$/)
		{
			next;
		}
		a[$1] = $2;
	}
	else if(FILENAME == ARGV[2] || FILENAME == ARGV[3] || FILENAME == ARGV[4] || FILENAME == ARGV[5])
	{
		a[$1] = 1;
	}
	else
	{
		# 减少挖掘出的tag数
		n = split($3, arr, "\\$\\$");
		if(n > 5)
		{
			new_tag = "";
			new_tag_cnt = 0;
			for(i = 1; i <= n; i++)
			{
				if(length(arr[i]) == 0)
				{
					next;
				}
				new_tag = new_tag == "" ? arr[i] : new_tag"\$\$"arr[i];
				if(++new_tag_cnt >= 5)
				{
					break;
				}
			}
			$3 = new_tag;
		}

		if(length($3) > 0)
		{# 已经有tag的，不再挖掘
			print $1"\t"$2"\t"$3"\t";
			next;
		}

		# 疑似tag
		n = split($4, arr, " ");
		tag = "";
		tag_n = 0;
		delete tag_hash;
		for(i = 1; i <= n; i++)
		{
			if(arr[i] in tag_hash)
			{
				continue;
			}
			tag_hash[arr[i]] = 1;
			if(arr[i] in a)
			{
				tag = tag == "" ? arr[i] : tag"$$"arr[i];
				tag_n++;
			}
		}
		tag = tag_n <= 5 ? tag : "";
		print $1"\t"$2"\t"$3"\t"tag;

	}
}' ${tag_list} ${person_name} ${area_tag} ${humor_tag} ${area} ${input} > ${temp}.tag
if [ ${?} -ne 0 ]
then
	echo "add tag failed!"
	exit 1
fi

# output
rm -rf ${output}.bak
cp ${output} ${output}.bak
cp ${temp}.tag ${output}

exit 0
