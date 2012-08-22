#!/bin/bash

# 目标tag：
# 1、美女帅哥  : 风格类型
# 		明星   : 人名
# 2、风景/旅行 : 近义词或者同义词表述、景点
# 3、趣味/搞笑 : 近义词或者同义词表述、描述具体类型、特定系列事情、
# 		猎奇   :
# 4、时尚/搭配/服饰 : 近义词或者同义词表述、风格类型、内容；
# 5、家具/装饰      : 风格类型、内容；


#objurl \t furl \t width \t height \t img_width \t img_height \t cont_sign1\t cont_sign2 \t obj_type \t sensitive \t is_gif_img \t is_gray_img \t ct0 \t ct2 \t at \t alt \t title \t real_title \t mypos \t keyword \t page_type \t pt_number \t usable \t uniq

#{ keyword, title, alt, ct}
#{ct0 , ct2 , at , alt , title , real_title , mypos , keyword}
#awk -F'	' '{
#	printf("%s\t%s",$1,$2);
#	for(i = 13; i <= 20; i++)
#	{
#		printf("\t%s", $i);
#	}
#	printf("\n");
#}' ./data/output > ./data/need_info

## mishang
#fgrep '收集此图到' ./data/need_info > cand_tag
#
#awk -F'	' '{
#	gsub(/^.*?收集此图到/, " ", $3);
#	gsub(" ", "", $3);
#	gsub(/[0-9]+张/, "", $3);
#	if(length($3))
#	{
#		print $3;
#	}
#}' cand_tag | awk -F'	' '{ a[$1]++;}END{for(i in a) { print i"\t"a[i];}}' | sort -t'	' -r -n -k2,2 > freq_tags

### keyword
#awk -F'	' '{
#	split($8, arr, " ");
#	for(i in arr)
#	{
#		if(arr[i] !~ /^[a-zA-Z]+$/)
#		{
#			a[arr[i]]++;
#		}
#	}
#} END {
#	for(i in a)
#	{
#		print i"\t"a[i];
#	}
#}' ./data/need_info > ./data/kw
#
#sort -t'	' -r -n -k2,2 ./data/kw > ./data/skw
#
#
### tag
#perl -MEncode -F"\t" -lane '{
#	if(index($F[1], "tag") >= 0) 
#	{
#		print $F[1]."\n";
#		$line = encode("gbk",decode("utf-8",$F[1]));
#		print $F[1]."\t".$line;
#	}
#}' ./data/need_info > cand_tag_1
#
#awk -F'	' '{
#	if(NF != 2)
#	{
#		next;
#	}
#	n = split($2, arr, "/");
#	for(i = 1; i <= n; i++)
#	{
#		if(index(arr[i], "tag"))
#		{
#			a[arr[i + 1]]++;
#		}
#	}
#} END {
#	for(i in a)
#	{
#		print i"\t"a[i];
#	}
#}' cand_tag_1 | sort -t'	' -r -n -k2,2 > scand_tag_1

#### tag
#perl -MEncode -F"\t" -lane '{
#	if(index($F[1], "tag") >= 0) 
#	{
#		$line = encode("gbk",decode("utf-8",$F[1]));
#		print $F[1]."\t".$line;
#	}
#}' ./data/part-00000 > cand_tag_1
#
#awk -F'	' '{
#	if(NF != 2)
#	{
#		next;
#	}
#	n = split($2, arr, "/");
#	for(i = 1; i <= n; i++)
#	{
#		if(index(arr[i], "tag"))
#		{
#			a[arr[i + 1]]++;
#		}
#	}
#} END {
#	for(i in a)
#	{
#		print i"\t"a[i];
#	}
#}' cand_tag_1 | sort -t'	' -r -n -k2,2 > scand_tag_1
#
#awk -F'	' '{ a[length($1)]++; }END{print tt; for(i in a) {  print i"\t"a[i];}}' scand_tag_1 | sort -t'	' -n -k1,1 | awk -F'	' '{ a[FNR] = $1; b[FNR] = $2; tt += $2;} END { for(i = 0; i < FNR; i++) { s += b[i]; print a[i]"\t"b[i]"\t"(s / tt);}}' 

## tag format
#  %20 -> p
#  {tag}?p=
#  search?tagname={tag}
#  
awk -F'	' '{
	if(length($1) >= 2 && length($1) <= 20)
	{
		print;
	}
	if(index($2, "%20"))
	{
		split($2, arr, "%20");
		for(i in arr)
		{
			print arr[i];
		}
	}
	else if(index($2, "?p="))
	{
		split($2, arr, "?");
		print arr[1];
	}
	else if(index($2, "search?tagname="))
	{
		split($2, "arr, "=");
		print arr[2];
	}
}' scand_tag_1 > scand_tag_2

## 1. 人名
awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $0;
	}
	else
	{
		if($1 in a)
		{
			print a[$1];
		}
	}
}' scand_tag_2 ./conf/person | sort -t'	' -r -n -k2,2 > o

## 2. 
