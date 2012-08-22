#!/bin/bash

pm_tag="./conf/tag_type_pm"
humor_tag="./conf/humor_tag"
area_tag="./conf/area_tag"
person="./conf/person"
area="./conf/area"
tag_cnt="./data/tag_cnt"

awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else if(FILENAME == "'${person}'")
	{
		print $1"\t"1"\t"a[$1];
	}
	else if(FILENAME == "'${pm_tag}'")
	{
		print $0"\t"a[$1];
	}
	else if(FILENAME == "'${humor_tag}'")
	{
		print $1"\t"3"\t"a[$1];
	}
	else if(FILENAME == "'${area_tag}'" || FILENAME == "'${area}'")
	{
		print $1"\t"2"\t"a[$1];
	}
}' ${tag_cnt} ${pm_tag} ${humor_tag} ${area_tag} ${area} | sort -t'	' -r -n -k3,3 | sort -t'	' -s -k2,2 > tag_type_cnt
