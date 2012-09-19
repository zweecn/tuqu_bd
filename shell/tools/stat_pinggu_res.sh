#!/bin/bash

tag_dir="data/img09/objInfoByTag.merge.0901"
tag_1_dir="data/img09/objInfoByTag.tag.1"
tag_o_dir="data/img09/objInfoByTag.tag.o"

death_link="data/img09/death_link"
all_tmp="data/img09/all_tmp"
all="data/img09/all"
objs_map="data/img09/objs_map"

#echo "Begin filter 0 result.."
#rm -rf $tag_1_dir
#mkdir $tag_1_dir
#rm $all_tmp
#while read tag
#do
#	tag_path="${tag_dir}/${tag}.txt"
#	tag_1_path="${tag_1_dir}/${tag}.txt"
#	awk -F '\t' '{
#		if ($4 == 1) {
#			print;	
#		}
#	}' $tag_path > ${tag_1_path}
#
#	cat $tag_1_path >> $all_tmp 
#
#done < conf/pinggu_res_tags
#
#sort -k1 $all_tmp | uniq > $all

#echo "Begin stat tags cnt..."
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		site[$1] = 1;
#	} else {
#		for (s in site) {
#			if (index($0, s)) {
#				print;
#			}
#		}
#	}
#}' conf/death_site data/img09/all > $death_link

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($5, tags, "\\$\\$");
#		for ( i in tags) {
#			tag = tags[i];
#			tag_cnt[tag]++;
#		}
#	} else {
#		print $1 "\t" tag_cnt[$1];	
#	}
#}' $all conf/pinggu_res_tags > data/img09/all.txt

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($5, tags, "\\$\\$");
#		for ( i in tags) {
#			tag = tags[i];
#			tag_cnt[tag]++;
#		}
#	} else {
#		print $1 "\t" tag_cnt[$1];	
#	}
#}' $death_link conf/pinggu_res_tags > data/img09/death_link.txt

#good="data/img09/good"
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		death[$1] = 1;
#	} else {
#		if ($1 in death)
#			next;
#		print;
#	}
#}' $death_link $all > $good
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($5, tags, "\\$\\$");
#		for ( i in tags) {
#			tag = tags[i];
#			tag_cnt[tag]++;
#		}
#	} else {
#		print $1 "\t" tag_cnt[$1];	
#	}
#}' $good conf/pinggu_res_tags > data/img09/good.txt

#echo "Make new pinggu..."
#rm -rf $tag_o_dir
#mkdir -p $tag_o_dir
#while read tag
#do
#	tag_1_path="${tag_1_dir}/${tag}.txt"
#	tag_o_path="${tag_o_dir}/${tag}.txt"
#	echo $tag_1_path
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			objs[$2] = $3;	
#		} else if (FILENAME == ARGV[2]) {
#			death[$1] = 1;
#		} else {
#			if ($1 in death)
#				next;
#			if ($2 in objs)
#				print $1 "\t" objs[$2] "\t" $3 "\t" $4 "\t" $5 "\t" $6; 
#			else 
#				print > "data/img09/no_local_link";
#		}
#	}' $objs_map $death_link $tag_1_path > ${tag_o_path}
#
#done < conf/pinggu_res_tags

echo "Begin scp..."
base_dir="data/img09/objInfoByTag.tmp"
#rm -rf $base_dir
#mkdir $base_dir
#while read tag
#do
#	path_in="data/img09/objInfoByTag.important.20120904/${tag}.txt" 
#	path_out="${base_dir}/${tag}.txt"
#	cp $path_in $path_out
#	echo -e "$path_in `cat $path_in | wc -l` --> $path_out `cat $path_out | wc -l`"
#done < conf/56_tags
#
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		used[$1] = 1;
#	} else {
#		if ($1 in used)
#			next;
#		print;
#	}
#}' conf/56_tags conf/tag > conf/other_tag
#
#while read tag
#do
#	path_in="data/img09/objInfoByTag/${tag}.txt" 
#	path_out="${base_dir}/${tag}.txt"
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			objs_map[$1] = $2;	
#		} else if (FILENAME == ARGV[2] || FILENAME == ARGV[3]) {
#			filter[$1] = 1;
#		} else {
#			if ($1 in filter)
#				next;
#			if ($1 in objs_map && !mark[$1]) {
#				mark[$1] = 1;
#				print $1 "\t" objs_map[$1] "\t" $3 "\t" $4 "\t" $5 "\t" $6;	
#			}
#		}
#	}' data/input/objs_local_map data/temp/all_death data/temp/all_zero ${path_in} > ${path_out}
#	echo -e "$path_in `cat $path_in | wc -l` --> $path_out `cat $path_out | wc -l`"
#done < conf/other_tag
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		used[$1] = 1;
#		delete tag_hash;
#		delete tags;
#		split($5, tags, "\\$\\$");
#		for ( i in tags) {
#			tag = tags[i];
#			if (tag == "创意家居") {
#				tag_hash["创意"] = 1;
#			} else if (tag != "") {
#				tag_hash[tag] = 1;
#			}
#		}
#		tag_str = "";
#		for (tag in tag_hash) {
#			if (tag_str == "")
#				tag_str = tag;
#			else 
#				tag_str = tag_str "$$" tag;
#		}
#		
#		delete tag_hash;
#		delete tags;
#		split($6, tags, "\\$\\$"); 
#		for ( i in tags) {
#			tag = tags[i];
#			if (tag == "创意家居") {
#				tag_hash["创意"] = 1;
#			} else if (tag != "") {
#				tag_hash[tag] = 1;
#			}
#		}
#		desc_str = "";
#		for (tag in tag_hash) {
#			if (desc_str == "")
#				desc_str = tag;
#			else 
#				desc_str = desc_str "$$" tag;
#		}
#		print $1 "\t" $2 "\t" $3 "\t" $4 "\t" tag_str "\t" desc_str;
#	} else {
#		if ($1 in used)
#			next;
#		delete tag_hash;
#		delete tags;
#		split($5, tags, "\\$\\$"); 
#		for ( i in tags) {
#			tag = tags[i];
#			if (tag == "创意家居") {
#				tag_hash["创意"] = 1;
#			} else if (tag != "") {
#				tag_hash[tag] = 1;
#			}
#		}
#		tag_str = "";
#		for (tag in tag_hash) {
#			if (tag_str == "")
#				tag_str = tag;
#			else 
#				tag_str = tag_str "$$" tag;
#		}
#		
#		delete tag_hash;
#		delete tags;
#		split($6, tags, "\\$\\$"); 
#		for ( i in tags) {
#			tag = tags[i];
#			if (tag == "创意家居") {
#				tag_hash["创意"] = 1;
#			} else if (tag != "") {
#				tag_hash[tag] = 1;
#			}
#		}
#		desc_str = "";
#		for (tag in tag_hash) {
#			if (desc_str == "")
#				desc_str = tag;
#			else 
#				desc_str = desc_str "$$" tag;
#		}
#		print $1 "\t" $2 "\t" $3 "\t" $4 "\t" tag_str "\t" desc_str;
#	}
#}' ${base_dir}/创意.txt ${base_dir}/创意家居.txt > ${base_dir}/创意_new.txt

#cat ${base_dir}/* > data/temp/all
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		tag_modi[$1] = $2;
#	} else if (FILENAME == ARGV[2]) {
#		zero[$1] = 1;
#	} else {
#		if (!mark[$1] && !($1 in zero)) {
#			mark[$1] = 1;
#			delete tag_hash;
#			delete tags;
#			split($5, tags, "\\$\\$"); 
#			for ( i in tags) {
#				tag = tags[i];
#				if (tag in tag_modi) {
#					tag_hash[tag_modi[tag]] = 1;
#				} else if (tag != "") {
#					tag_hash[tag] = 1;
#				}
#			}
#			tag_str = "";
#			for (tag in tag_hash) {
#				if (tag_str == "")
#					tag_str = tag;
#				else if (tag != "") 
#					tag_str = tag_str "$$" tag;
#			}
#			
#			delete tag_hash;
#			delete tags;
#			split($6, tags, "\\$\\$"); 
#			for ( i in tags) {
#				tag = tags[i];
#				if (tag in tag_modi) {
#					tag_hash[tag_modi[tag]] = 1;
#				} else if (tag != "") {
#					tag_hash[tag] = 1;
#				}
#			}
#			desc_str = "";
#			for (tag in tag_hash) {
#				if (desc_str == "")
#					desc_str = tag;
#				else if (tag != "") 
#					desc_str = desc_str "$$" tag;
#			}
#			print $1 "\t" $2 "\t" $3 "\t" $4 "\t" tag_str "\t" desc_str;
#		}
#	}
#}' conf/tag_modi_last data/img09/all_zero data/temp/all > data/temp/all_demo.tmp
#
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($5, tags, "\\$\\$");
#		for (i in tags) {
#			tag = tags[i];
#			tag_cnt[tag]++;
#		}
#	} else {
#		print $1 "\t" tag_cnt[$1];
#	}
#}' data/temp/all_demo.tmp conf/tag > data/temp/all_demo_tag_cnt 
#
##awk -F '\t' '{
##	if (FILENAME == ARGV[1]) {
##		if (!mark[$1]) {
##			mark[$1] = 1;
##			split($5, tags, "\\$\\$");
##			for (i in tags) {
##				tag = tags[i];
##				if (tag == "时尚") {
##					print;
##					break;
##				}
##			}
##		}
##	}
##}' data/output/all_demo > data/img09/shishang.txt
#
#demo_dir="data/img09/objInfoByTag.demo"
#rm -rf $demo_dir
#mkdir -p $demo_dir
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		pass_tag[$1] = 1;
#	} else {
#		split($5, tags, "\\$\\$");
#		for (i in tags) {
#			tag = tags[i];
#			if (tag in pass_tag)
#				print > "'${demo_dir}'" "/" tag ".txt";
#		}
#	}
#}' conf/tag data/temp/all_demo.tmp
#
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		tag_list[$1] = 1;
#	} else if (FILENAME == ARGV[2]) {
#		
#	}
#}' conf/tag data/output/all_demo

#dir_out="data/img09/objInfoByTag.tmp.o"
#rm -rf $dir_out
#mkdir -p $dir_out
#while read tag type
#do
##scp img@tc-apptest-img09.vm.baidu.com:/home/img/lighttpd_8088/htdocs/objInfoByTag/${tag}.txt $base_dir 
#	path="${base_dir}/${tag}.txt"
#	path_out="${dir_out}/${tag}.txt"	
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			type_list[$2] = 1;
#		} else {
#			delete tags;
#			delete tag_hash;
#			split($5, tags, "\\$\\$");
#			for (i in tags) {
#				tag = tags[i];
#				if (tag in type_list) {
#					tag_hash["'${type}'"] = 1;
#				} else {
#					tag_hash[tag] = 1;	
#				}
#			}
#			if ("'${tag}'" in tag_hash && "'${type}'" in tag_hash) {
#				print $0 "\t" "'${type}'";
#			}
#		}
#	}' conf/tag_type $path > ${path_out}
#
#	echo -e "${tag}\t`wc -l $path | cut -d' ' -f1` `wc -l ${path_out} | cut -d' ' -f1`"
#done < conf/tag_type

#awk -F '\t' '{
#	if (FILENAME == ARGV[1] ) {
#		type_index[$2] = $1;
#	} else if(FILENAME == ARGV[2]) {
#		tag_type[$1] = $2;	
#	} else {
#		if ($1 in tag_type)
#			print $1 "\t" tag_type[$1];
#		else 
#			print $1 "\t" type_index[$2];
#	}
#}' conf/all_type_index conf/tag_type conf/tag_list > conf/all_type_index_str
#
#awk -F '\t' '{
#	if (type[$1] != "")
#		type[$1] = type[$1] "$$" $2;
#	else 
#		type[$1] = $2;
#} END {
#	for ( i in type) {
#		if (index(type[i], "$$"))
#			print i "\t" type[i];
#	}
#}' conf/all_type_index_str

#while read tag type
#do
#	path="${base_dir}/${tag}.txt"
#	line=`wc -l $path | cut -d' ' -f 1`
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			types[$1] = 1;
#		} else {
#			split($5, tags, "\\$\\$");
#			for (i in tags) {
#				tag = tags[i];
#				if (tag in types) {
#					type_hash[tag] = 1;	
#				}
#			}
#		}
#	} END {
#		type_str = "";
#		for (t in type_hash) {
#			if (type_str == "") 
#				type_str = t;
#			else 
#				type_str = type_str "," t;
#		}
#		print "'${tag}'" "\t" "'${type}'" "\t" type_str "\t" "'${line}'";
#		delete type_hash;
#	}' conf/all_type_index $path
#done < conf/tag_type_sort

tag_o_dir="data/img09/objInfoByTag.tmp.o"
#tmp1="data/img09/all_tmp.tmp1"
#tmp2="data/img09/all_tmp.tmp2"
#rm -rf $tmp1
#rm -rf $tmp2
#touch $tmp2
#touch $tmp1
#while read tag type
#do
#	path="${base_dir}/${tag}.txt"
#	path_out="${tag_o_dir}/${tag}.txt"
#	line=`wc -l $path | cut -d' ' -f 1`
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			types[$1] = 1;
#		} else if (FILENAME == ARGV[2]) {
#			used[$1] = $2;
#		} else {
#			delete type_hash;
#			split($5, tags, "\\$\\$");
#			for (i in tags) {
#				tag = tags[i];
#				if (tag in types) {
#					tag = "'${type}'"
#				}
#				if (tag == "风尚")
#					tag = "时尚";
#				type_hash[tag] = 1;	
#			}
#			type_str = "";
#			for (t in type_hash) {
#				if (type_str == "") 
#					type_str = t;
#				else 
#					type_str = type_str "," t;
#			}
#			if ($1 in used && used[$1] != "'${type}'") {
#				next;
#			} else  {
#				print $1 "\t" $2 "\t" $3 "\t" $4 "\t" type_str "\t" $6;	
#				print $1  "\t" "'${type}'" > "'${tmp1}'"
#			}
#		}
#	}' conf/all_type_index $tmp2 $path > $path_out
#	cat $tmp1 >> $tmp2
#
#	echo -e "`wc -l ${path}` --> `wc -l ${path_out}`"
#
#done < conf/tag_type_sort

#cat data/img09/objInfoByTag.tmp.o/* | awk -F '\t' '{
#	if (!mark[$1]) {
#		print;
#		mark[$1] = 1;
#	}
#}' > data/img09/all_demo

#cut -f3 data/img09/all_demo | perl -lne '{
#	if ($_ =~ /(\w+\.\w+)\//) {
#			print $1;
#		}
#}' | sort | uniq > data/img09/all_site

rm -rf data/img09/site_cnt
while read tag type
do

	path_out="${tag_o_dir}/${tag}.txt"
	cut -f3 $path_out | perl -lne '{
		if ($_ =~ /(\w+\.\w+)\//) {
			print "$_\t$1";
		}
	}' > data/img09/site_domain

	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			site_cnt[$2]++;
			all_cnt++;
		} else {
			if (!str)
				str = $1 ":" (site_cnt[$1] == 0 ? 0 : site_cnt[$1]);
			else
				str = str "\t" $1 ":" (site_cnt[$1] == 0 ? 0 : site_cnt[$1]);
		}
	} END {
		print "'${tag}'" "\t" "'${type}'" "\t" all_cnt "\t" str;
	}'  data/img09/site_domain data/img09/all_site >> data/img09/site_cnt

done < conf/tag_type


#type_tag_cnt="data/img09/type_tag_cnt"
#rm -rf $type_tag_cnt
#while read tag type
#do
#	path="${tag_o_dir}/${tag}.txt"
#	echo -e "${tag}\t`wc -l $path | cut -d' ' -f1`" >> $type_tag_cnt
#done < conf/tag_type

#cat data/img09/objInfoByTag.tmp.o/* | awk -F '\t' '{
#	if (!hash[$1]) {
#		hash[$1] = $5;
#	} else {
#		if ($5 != hash[$1])
#			print $1 "\t" $5 "\t" hash[$1];
#	}
#}'

#cat ${dir_out}/* | awk -F '\t' '{
#	if (!mark[$1]) {
#		mark[$1] = $NF;
#		print;
#	} 
#}' > data/img09/all 
#
#cat ${dir_out}/* | awk -F '\t' '{
#
#}' | sort -k1 > data/img09/conflict
#
#awk -F '\t' '{
#
#}' 

#echo "Begin select death..."
#awk -F '\t' '{
#	if (!mark[$1]) {
#		mark[$1] = 1;
#		if ($4 != 0)
#			print;
#	}
#}' data/temp/all_tmp > data/temp/all_tmp.uniq


#rm -rf  data/temp/all_death
#while read tag
#do
#	old="${base_dir}/${tag}.txt "
##	cat ${base_dir}/${tag}.txt >> data/temp/all_death
#	path="${base_dir}/${tag}_local.txt"
#	path_new="${base_dir}/${tag}_new.txt"
#	
#	awk -F '\t' '{
#		if ($4 == 0) {
#			print;
#		}
#	}' $old $path_new > ${path}.zero
#	
#	awk -F '\t' '{
#		if (FILENAME == ARGV[1]) {
#			zero[$1] = 1;
#		} else if (FILENAME == ARGV[2]) {
#			death[$1] = 1;
#		} else if (FILENAME == ARGV[3]) {
#			local[$1] = $2;
#		} else {
#			if ($1 in zero)
#				next;
#			flag = 0;
#			for (s in death) {
#				if(index($0, s)) {
#					flag = 1;
#					break;
#				}
#			}
#			if (!flag)
#				print $1 "\t" local[$1] "\t" $3 "\t" $4 "\t" $5 "\t" $6;
#		}
#	}' ${path}.zero conf/death_site data/input/all_pinggu_local $old > $path
#	
#	echo $path $old
#	mv "$old" ${old}.old
#	mv "$path" $old
#done < conf/filter_death_tags

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		death[$1] = 1;
#	} else {
#		for (s in death) {
#			if (index($0, s)) {
#				print;
#				break;
#			}
#		}
#	}
#}' conf/death_site data/temp/all_death > data/temp/death

#echo "Begin cal tag cnt..."
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		death[$1] = 1;	
#	} else if (FILENAME == ARGV[2]) {
#		if ($1 in death || $4 == 0)
#			next;
#		split($5, tags, "\\$\\$");
#		for ( i in tags) {
#			tag = tags[i];
#			tag_cnt[tag]++;
#		}
#	} else {
#		print $1 "\t" tag_cnt[$1];	
#	}
#}' data/temp/death data/temp/all_tmp.uniq conf/pm_tags > data/img09/good.txt



#good="data/img09/good"
#cat data/img09/objInfoByTag.tmp/* | sort | uniq > $good 
#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		split($5, tags, "\\$\\$");
#		for ( i in tags) {
#			tag = tags[i];
#			tag_cnt[tag]++;
#		}
#	} else {
#		print $1 "\t" tag_cnt[$1];	
#	}
#}' $good conf/pm_tags > data/img09/good.txt

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		tag_list[$1] = 1;
#	} else if (FILENAME == ARGV[2]) {
#		tag_obj[$2] = tag_obj[$2] "$$" $1; 	
#	} else {
#		split($5, tags, "\\$\\$");
#		delete tag_hash;
#		for (i in tags) {
#			tag = tags[i];
#			if (tag in tag_list && index(tag_obj[tag], $1)) {
#				tag_hash[tag] = 1;		
#			} else if (!(tag in tag_list)) {
#				tag_hash[tag] = 1;
#			}
#		}
#		tag_str = "";
#		for (tag in tag_hash) {
#			if (tag_str == "") {
#				tag_str = tag;
#			} else {
#				tag_str = tag_str "$$" tag;
#			}
#		}
#		if (tag_str != "")
#			print $1 "\t" $2 "\t" $3 "\t" $4 "\t" tag_str "\t" $6;
#	}
#}' conf/tag data/img09/pass_obj_tag data/output/all_demo > data/img09/all_demo.tmp

echo "Finished."
