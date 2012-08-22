#!/bin/bash

temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
input="./data/output.thumb"
#input="./data/temp/tests_jinsong.input";
tag_type="./data/tag_type.txt";
output=${temp}.tag_type
#output=${temp}.tag_type_conflict;

awk -F '\t' 'BEGIN{
	tag_type_str["1"]="美女帅哥";
	tag_type_str["2"]="风景/旅行";
	tag_type_str["3"]="趣味搞笑";
	tag_type_str["4"]="时尚搭配服饰";
	tag_type_str["5"]="家居装饰";
}{
	if(FILENAME==ARGV[1]){
		if($3!=""){
			tag_type[$1]=tag_type_str[$3];
			tag_freq[$1]=$2;
		}
	}else{
		tags=$3;
		split($3,tags_set,"$");
		delete types;
		for(tag_index in tags_set){
			a_tag=tags_set[tag_index];
			if(a_tag!=""){
				a_tag_type=tag_type[a_tag];
				if(a_tag_type!="" &&  types[a_tag_type]<tag_freq[a_tag]){
					types[a_tag_type]=tag_freq[a_tag];
				}
#	print "tag="a_tag"\ttype="a_tag_type;
			}
		}
		conflict_mark=0;
		types_string="";
		for(type in types){
			if(types_string==""){
				types_string=type;
			}else{
				#选tag频率最高的类型作为该obj的类型
				if(types[type]>types[types_string]);
					types_string=type;
			}
		}
		if(types_string!=""){
			print $2"\t"$6"\t"$5"\t"tags"$$"types_string;
		}
	}
}' ${tag_type} ${input} > ${output}; 
