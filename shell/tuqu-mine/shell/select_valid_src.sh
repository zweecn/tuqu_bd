#!/bin/bash

temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
input="./data/merged"
#input="./data/tag_parser.out";
output="./data/source_valid"

### 1. select objects with aim patterns. use hadoop
awk -F'	' 'BEGIN {
	OFS = "\t";

	pt[1] = "http://www.huaban.com/pins/";
	pt[2] = "http://faxianla.com/mark/";
	pt[3] = "http://www.zhimei.com/share/";
	pt[4] = "http://www.pinfun.com/pin/";
	pt[5] = "http://www.meilishuo.com/share/";
	pt[6] = "http://www.woxihuan.com/";
	ptn = 6;

#	http://www.huaban.com/pins/
#	http://faxianla.com/mark/
#	http://www.zhimei.com/share/1614918
#	http://www.pinfun.com/pin/162358/
#	http://www.meilishuo.com/share/285408495
#	http://www.woxihuan.com/32196495/1339480383080740.shtml
}
{
	if($5 < 400 && $6 < 400)
	{# size
		next;
	}
#	is_hit = 0;
#	for(i = 1; i <= ptn; i++)
#	{
#		if(index($2, pt[i]))
#		{
#			is_hit = 1;
#		}
#	}
#	if(is_hit == 0)
#	{
#		next;
#	}
#	
	## format
	#http://b.imimg.cn/20120404/6973/6966/6a6a597a/1333523837490.1138.540.540.jpg    http://www.zhimei.com/share/132812
	if(index($2, "zhimei") && index($1, "http://b.imimg.cn"))
	{
		n = split($1, arr, ".");
		arr[n - 4] = 0;
		str = "";
		for(i = 1; i < n; i++)
		{
			str = str"."arr[i];
		}
		str = str"."arr[n];
		$1 = str;
	}
	print;
}' ${input} > ${temp}.aim_pt
if [ ${?} -ne 0 ]
then
	echo "select aim picture failed!"
	exit 1
fi

### 2. select the largest picture each from_url
#sort -t'	' -k2,2 ${temp}.aim_pt > ${temp}.aim_pt_sort
sort -t'	' -k2,2 -T ./data/ ${input} > ${temp}.aim_pt_sort;
if [ ${?} -ne 0 ]
then
	echo "sort aim pt failed!"
	exit 1
fi

awk -F'	' '{
	if($2 != from_url)
	{
		if(from_url)
		{
			print max_sz_info;
		}

		max_sz_info = "";
		max_sz = -1;
		from_url = $2;
	}
	sz1 = $3 * $4;
	sz2 = $5 * $6;
	sz = sz1 > sz2 ? sz1 : sz2;
	if(sz > max_sz)
	{
		max_sz = sz;
		max_sz_info = $0;
	}
} END {
	if(from_url)
	{
		print max_sz_info;
	}
}' ${temp}.aim_pt_sort > ${temp}.uniq_aim_pt_sort
if [ ${?} -ne 0 ]
then
	echo "uniq aim pt sort failed!"
	exit 1
fi

## 3. remove useless column
awk -F'	' '{
	# site
	n = split($2, arr, "/");
	printf("%s\t%s\t%s", arr[3], $1, $2);

	for(i = 13; i <= 20; i++)
	{
		gsub(/^[ ]+|[ ]+$/, "", $i);
		printf("\t%s", $i);
	}
	printf("\t%s\n", $26); ## tag
}' ${temp}.uniq_aim_pt_sort > ${temp}.rm_useless_column
if [ ${?} -ne 0 ]
then
	echo "remove useless cont failed!"
	exit 1
fi


## 3.1 remove same picture in juetuzhi
awk -F'	' '{
	if($1 == "juetuzhi.net" && match($2, /[0-9a-fA-F]+\_[0-9a-fA-F]+\.jpg$/))
	{
		key = substr($2, RSTART, RLENGTH);
		if(key in a)
		{
			print > "rm";
			next;
		}
		print;
		a[key] = 1;
	}
	else
	{
		print;
	}
}' ${temp}.rm_useless_column > ${temp}.out
if [ ${?} -ne 0 ]
then
	echo "[$0] rm useless column failed!"
	exit 1
fi

## 4. output
rm -rf ${output}.bak
mv ${output} ${output}.bak
cp ${temp}.out ${output}

exit 0

