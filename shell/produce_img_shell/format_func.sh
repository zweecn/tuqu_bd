#!/bin/bash

#############################################################################
# 
# format数据的函数脚本
# 适用于挖掘数据和定向数据的格式化
# 调用前先执行 source ./shell/produce_img/format_func.sh
#
#############################################################################

### 1. 清洗 tag，去掉没有tag 的obj，把tag中的空格替换为_，用,分割tag,去掉重复的tag,去掉空tag
function clean_tag
{
    local func_input=$1
    local func_output=$2
	local no_tag=$3
	echo -e "	清洗tag前，输入文件为 ${func_input} `wc -l ${func_input} | cut -d ' ' -f 1` 行"
    awk -F '\t' -v out="${no_tag}" '{
		# objURL    fromURL     tags
		if($1=="" || $2=="" || $3==""){
			print $0 > out;
			next;
		}
		gsub("、","$$",$3);
		gsub("\\/","$$",$3);
		gsub("&&","$$",$3);
		split($3,tags,"\\$\\$");
		# 图趣要求tag中不能有空格！且tag需用,分割
		delete tag_set;
		tag_str="";
		for(i in tags){
			tag=tags[i];
			if(tag=="")
				continue;
			gsub(" ","_",tag);
			gsub(",","_",tag);
			## 统一为小写字母
			tag_set[tolower(tag)]=1;
		}
		for(tag in tag_set){
			if(tag_str==""){
				tag_str=tag;
			}else{
				tag_str=tag_str","tag;
			}
		}
		if(tag_str!="")
			print $1"\t"$2"\t"tag_str;
    }' ${func_input} > ${func_output}
	echo -e "	清洗tag后，输出文件为 ${func_output} `wc -l ${func_output} | cut -d ' ' -f 1` 行"
	echo -e "	没有tag的图片，输出为 ${no_tag} `wc -l ${no_tag} | cut -d ' ' -f 1` 行"
}

### 2. 计算tag频率
function cal_tag_freq
{
	local data_clean_tag=$1
	local tag_freq=$2
	awk -F '\t' '{
    	split($3,tags,",");
    	for(i in tags){
        	tag=tags[i];
        	count[tag]++;
    	}
	}END{
    	for(tag in count){
        	print tag"\t"count[tag];
    	}
	}' ${data_clean_tag} > ${tag_freq}
	echo -e "	计算tag频率输出为 ${tag_freq}"
}

### 3. 确定pm的大分类
#function determine_tag_type
#{
#	echo -e "	确定PM大分类的输入文件是 $1 `wc -l $1 | cut -d ' ' -f 1` 行"
#   	local func_input=$1;
#   	local func_tag_type_conf=$2;
#    local func_output=$3;
#    local func_conflict_output=$4;
#	local no_type_out=$5;
#    awk -F '\t' -v conflict_output="${func_conflict_output}" -v no_out="${no_type_out}" '{
#        if(FILENAME==ARGV[1]){
#            tag_type[$1]=$2;
#        }else if(FILENAME==ARGV[2]){
#            tag_freq[$1]=$2;
#        }else{
#            split($3,tags,",");
#			delete types;
#            for(i in tags){
#                tag=tags[i];
#                if(tag!="" && (tag in tag_type)){ # tag必须在白名单中
#                    a_type=tag_type[tag];
#                    if(a_type!="" &&  tag_freq[types[a_type]]<tag_freq[tag]){  ## 同一类型下的最高频率
#                         ##print tag"*"a_type"*"tag_freq[types[a_type]]"*"tag_freq[tag];
#                         types[a_type]=tag;
#                    }
#                }
#            }
#            conflict_mark=0;
#            top_freq_tag=""; # 最高频率的tag
#            for(type in types){
#                if(top_freq_tag=="")
#                    top_freq_tag=types[type];
#                else{
#                    #选tag频率最高的类型作为该obj的类型
#                    tag=types[type];
#                    if(tag_freq[tag]>tag_freq[top_freq_tag])
#                        top_freq_tag=tag;
#                    conflict_mark=1;
#                }
#            }
#            ##print $3"*"top_freq_tag"*"tag_type[top_freq_tag];
#			
#			if(conflict_mark==1){ #前后数据有10W条冲突的,有必要挖掘出来
#                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag] > conflict_output;
#            } else if(top_freq_tag!=""){
#                # objURL    fromURL tags    top_freq_tag    type
#                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag];
#            } else {
#                print $0 > no_out;
#			}
######################
##            if(top_freq_tag!=""){
##                # objURL    fromURL tags    top_freq_tag    type
##                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag];
##            } 
##			 if(conflict_mark==1){ #前后数据有10W条冲突的,有必要挖掘出来
##                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag] > conflict_output;
##			 }
########################################################################################################
#
#        }
#    }' ${func_tag_type_conf} ${tag_freq}  ${func_input} > ${func_output}
#	echo -e "	确定PM大分类后，输出文件为 ${func_output} `wc -l ${func_output} | cut -d' ' -f 1` 行"
#	echo -e	"	冲突文件为 ${func_conflict_output} `wc -l ${func_conflict_output} | cut -d' ' -f 1` 行"
#	echo -e	"	没被分类的为 ${no_type_out} `wc -l ${no_type_out} | cut -d' ' -f 1` 行"
#}

function determine_tag_type
{
	echo -e "	确定PM大分类的输入文件是 $1 `wc -l $1 | cut -d ' ' -f 1` 行"
   	local func_input=$1;
   	local func_tag_type_conf=$2;
    local func_output=$3;
    local func_conflict_output=$4;
	local no_type_out=$5;
	local pm_stat_tags=$6;
	local stat_tag=$7; 
	awk -F '\t' -v stat_tag_out="${stat_tag}" -v conflict_output="${func_conflict_output}" -v no_out="${no_type_out}" '{
        if (FILENAME == ARGV[1]) {
			pm_tag_cnt[$1] = $2;	
			total_tag_cnt[$1] = 0;
			conflict_tag_cnt[$1] = 0;
			no_tag_cnt[$1] = 0;
			tag_left_cnt[$1] = 0;
		}else if(FILENAME==ARGV[2]){
            tag_type[$1]=$2;
        }else if(FILENAME==ARGV[3]){
            tag_freq[$1]=$2;
        }else{
			split($3,tags,",");
			delete types;
            for(i in tags){
                tag=tags[i];
                if(tag!="" && (tag in tag_type)){ # tag必须在白名单中
                    a_type=tag_type[tag];
                    if(a_type!="" &&  tag_freq[types[a_type]]<tag_freq[tag]){  ## 同一类型下的最高频率
                         ##print tag"*"a_type"*"tag_freq[types[a_type]]"*"tag_freq[tag];
                         types[a_type]=tag;
                    }
                }
            }
            conflict_mark=0;
            top_freq_tag=""; # 最高频率的tag
            for(type in types){
                if(top_freq_tag=="")
                    top_freq_tag=types[type];
                else{
                    #选tag频率最高的类型作为该obj的类型
                    tag=types[type];
                    if(tag_freq[tag]>tag_freq[top_freq_tag])
                        top_freq_tag=tag;
                    conflict_mark=1;
                }
            }
            ##print $3"*"top_freq_tag"*"tag_type[top_freq_tag];
			
			if(conflict_mark==1){ #前后数据有10W条冲突的,有必要挖掘出来
                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag] > conflict_output;
            } else if(top_freq_tag!=""){
                # objURL    fromURL tags    top_freq_tag    type
                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag];
            } else {
                print $0 > no_out;
			}

			for (i in tags) {
				tag = tags[i];
				if (!(tag in pm_tag_cnt)) {
					continue;
				}

				total_tag_cnt[tag]++;		
				if (conflict_mark) {
					conflict_tag_cnt[tag]++;
				} else if (top_freq_tag != "") {
					tag_left_cnt[tag]++;
				} else {
					no_tag_cnt[tag]++;
				}
			}
        }
    } END {
#		print "tag \t PM统计值 \t 去掉无tag后统计值 \t = 冲突统计值 + 无分类值 + 有效统计值" > stat_tag_out;
		for (tag in pm_tag_cnt) {
			print tag "\t" pm_tag_cnt[tag] "\t" total_tag_cnt[tag] "\t" conflict_tag_cnt[tag] "\t" no_tag_cnt[tag] "\t" tag_left_cnt[tag] > stat_tag_out; 
		}
	}' ${pm_stat_tags} ${func_tag_type_conf} ${tag_freq}  ${func_input} > ${func_output}
	echo -e "	确定PM大分类后，输出文件为 ${func_output} `wc -l ${func_output} | cut -d' ' -f 1` 行"
	echo -e	"	冲突文件为 ${func_conflict_output} `wc -l ${func_conflict_output} | cut -d' ' -f 1` 行"
	echo -e	"	没被分类的为 ${no_type_out} `wc -l ${no_type_out} | cut -d' ' -f 1` 行"
	echo -e "	tag 统计结果输出为 ${stat_tag}"
}


### 4 修改一些tag为另外的tag（根据PM的配置: conf/*_tag_modified)
function tag_modify
{
	local tag_freq=$1
	local suffix_modified_tag=$2
	local suffix_data_tag_type=$3
	local tag_modify_out=$4
	local tag_freq_modified=$5
	awk -F '\t' -v out="${tag_modify_out}" '{
		if(FILENAME==ARGV[1]){
			tag_freq[$1]=$2;
		}else if(FILENAME==ARGV[2]){
			suffix_tag_change[$1]=$2;
			if(!($2 in tag_freq))
				tag_freq[$2]=tag_freq[$1];
		}else if(FILENAME==ARGV[3]){
			split($3,tags,",");
			tag_str="";
			for(i in tags){
				tag=tags[i];
#				if (tag == "欧美风") {
#					print tag"\t"suffix_tag_change[tag] > "o1";
#				}
				if(tag in suffix_tag_change){
					tag=suffix_tag_change[tag];
					
				}
				if(tag_str=="")
					tag_str=tag;
				else
					tag_str=tag_str","tag;
			}
			top_tag=($4 in suffix_tag_change)?suffix_tag_change[$4]:$4;
			print $1"\t"$2"\t"tag_str"\t"top_tag"\t"$5 > out;
		}	
	} END {
		for(tag in tag_freq){
				print tag"\t"tag_freq[tag];
		}
	}' ${tag_freq} ${suffix_modified_tag} ${suffix_data_tag_type} > ${tag_freq_modified}
	echo -e "	修改一些tag为另外的tag后，输出文件为 ${tag_modify_out} `wc -l ${tag_modify_out} | cut -d ' ' -f 1` 行"
}


### 5 去掉黑名单中的obj，去掉黑名单中的tag，限制tag数为5. 组成: 最高词频的2个 + 类型1个
function remove_black_tag 
{
	local black_objs=$1
	local black_tags=$2
	local type_index=$3
	local tag_freq_modified=$4
	local data_tag_type=$5
	local data_tag_type_filter_tags=$6
	local tag_type_list=$7

	awk -F '\t' '{
		if(FILENAME==ARGV[1]){
			obj_black[$1]=1;
		}else if(FILENAME==ARGV[2]){
			tag_black[$1]=1;
		}else if(FILENAME==ARGV[3]){
			type_index[$2]=$1;
		}else if(FILENAME==ARGV[4]){
			tag_type_pm[$1] = $2;	
		}else if(FILENAME==ARGV[5]){
			tag_freq[$1]=$2;
		}else{
			if($1 in obj_black){
				next;
			}
			split($3,tags,",");
			top_freq_tag=$4;

######################################################################			
# 修改策略后的版本
#			
			delete save_tag;
			if(!(top_freq_tag in tag_black)){
				save_tag[top_freq_tag] = 1;	
			}
			len=0;
			for (i in tags) {
				tag = tags[i];
				if (tag in tag_type_pm) {
					save_tag[tag] = 1;	
					len++;
				}
			}
			
			type=type_index[$5];
			tag1="";
			tag2="";
			tag3="";
			
			if (len == 0) {
				for(i in tags){
					tag=tags[i];
					# 取3个最高频的tag
					if(tag!=top_freq_tag && tag!=type && !(tag in tag_black)){
						if(tag1=="" || tag_freq[tag]>tag_freq[tag1]){
							tag1=tag;
						}else if(tag2=="" || tag_freq[tag]>tag_freq[tag2]){
							tag2=tag;
						}else if(tag3=="" || tag_freq[tag]>tag_freq[tag3]){
							tag3=tag;
						}
					}
				}
			} else if (len == 1) {
				for(i in tags){
					tag=tags[i];
					# 取2个最高频的tag
					if(tag!=top_freq_tag && tag!=type && !(tag in tag_black)){
						if(tag1=="" || tag_freq[tag]>tag_freq[tag1]){
							tag1=tag;
						}else if(tag2=="" || tag_freq[tag]>tag_freq[tag2]){
							tag2=tag;
						}
					}
				}
			} else if (len == 2) {
				for(i in tags){
					tag=tags[i];
					# 取1个最高频的tag
					if(tag!=top_freq_tag && tag!=type && !(tag in tag_black)){
						if(tag1=="" || tag_freq[tag]>tag_freq[tag1]){
							tag1=tag;
						}
					}
				}
			} else if (len >= 3) {
				for(i in save_tag){
					tag=i;
					if(tag!=top_freq_tag && tag!=type && !(tag in tag_black)){
						if(tag1=="" || tag_freq[tag]>tag_freq[tag1]){
							tag1=tag;
						}else if(tag2=="" || tag_freq[tag]>tag_freq[tag2]){
							tag2=tag;
						}else if(tag3=="" || tag_freq[tag]>tag_freq[tag3]){
							tag3=tag;
						}

					}
				}
			}
	
			delete final_tags;
			if (len < 3) {
				for (i in save_tag) {
					final_tags[i] = 1;
				}
			}
			
######################################################################			
#	修改策略前的版本
#			
#			type=type_index[$5];
#			tag1="";
#			tag2="";
#			tag3="";
#			for(i in tags){
#				tag=tags[i];
#				# 取4个最高频的tag
#				if(tag!=top_freq_tag && tag!=type && !(tag in tag_black)){
#					if(tag1=="" || tag_freq[tag]>tag_freq[tag1]){
#						tag1=tag;
#					}else if(tag2=="" || tag_freq[tag]>tag_freq[tag2]){
#						tag2=tag;
#					}else if(tag3=="" || tag_freq[tag]>tag_freq[tag3]){
#						tag3=tag;
#					}
#				}
#			}
#			delete final_tags;
#			if(!(top_freq_tag in tag_black)){
#				final_tags[top_freq_tag];
#			}
#
#####################################################################			
## 			把 时尚搭配服饰 拆成  时尚搭配 和 服饰
#			if($5==4){
#				final_tags["时尚搭配"];
#				final_tags["服饰"];
#			}else if($5==2){   ## 把 风景/旅行 拆成 风景 和 旅行
#				final_tags["风景"];
#				final_tags["旅行"];
#			}else if($5!=0){
#				final_tags[type_index[$5]];
#			}
######################################################################			
			
			delete final_tags;
			if($5!=0){
				final_tags[type_index[$5]];
			}
			if(!(top_freq_tag in tag_black)){
				final_tags[top_freq_tag];	
			}
			if(tag1!="") 
				final_tags[tag1];
			if(tag2!="")
				final_tags[tag2];
			if(tag3!="")
				final_tags[tag3];
			tag_cnt = 0;
			tag_str="";
			for( tag in final_tags){
				tag_cnt++;
				if(tag_str=="")
					tag_str=tag;
				else
					tag_str=tag_str","tag;
			}
			if (tag_cnt > 1 || ($5 == 0 && tag_cnt > 0)) {
				# objURL    fromURL     tags    top_freq_tag    type
				print $1"\t"$2"\t"tag_str"\t"top_freq_tag"\t"type;
			} else {
				print > "'${data_tag_type}.less_tags'"		
				print $1"\t"$2"\t"tag_str"\t"top_freq_tag"\t"type > "'${data_tag_type}.less_tags.after'";
			}
		}
	}' ${black_objs} ${black_tags} ${type_index} ${tag_type_list} ${tag_freq_modified} ${data_tag_type} > ${data_tag_type_filter_tags};
	echo -e "	去掉黑名单后输出文件为 ${data_tag_type_filter_tags} `wc -l ${data_tag_type_filter_tags} | cut -d' ' -f 1` 行"
	if [ -f ${data_tag_type}.less_tags ]; then
		echo -e "	tag数量少于2的输出文件为 ${data_tag_type}.less_tags `wc -l ${data_tag_type}.less_tags | cut -d ' ' -f 1` 行"
	fi
	if [ -f ${data_tag_type}.less_tags.after ]; then
		echo -e "	tag数量少于2的处理后输出文件为 ${data_tag_type}.less_tags.after `wc -l ${data_tag_type}.less_tags.after | cut -d ' ' -f 1` 行"
	fi
}

### **.dingxiang 在分类信息后增加每个站点信息, 更新每个类别需要的图片数量的配置
function update_type_and_demand
{
	local inout=$1
	local temp=$2
	echo "	** 定向数据需要统计来源数据占比..."
	perl -lne '{
		if ($_ =~ /\/\/(.*?)\/.+?\/\/(.*?)\//) { 
			@F = split(/\./, $2);
			$domain = $F[@F-2].".".$F[@F-1];
			print $domain."\t".$_;
		}
	}' ${inout} | awk -F '\t' '{
		domain_type = $1"-"$6;
		print $2 "\t" $3 "\t" $4 "\t" $5 "\t" domain_type;
	} END {
	}' > ${temp}

	mv ${inout} ${inout}.old
	echo -e "	备份${inout} 为 ${inout}.old"
	mv ${temp} ${inout}
	echo -e "	更新图片站点需求信息完成，输出为 ${inout} `wc -l ${inout} | cut -d' ' -f 1` 行"
}

### 6  随机打散obj
function rand_obj
{
	local data_tag_type_filter_tags=$1
	local temp=$2
	local output_without_path=$3
	awk -F '\t' '{
    	print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"rand();
	}' ${data_tag_type_filter_tags} > ${temp}.all_data.tag_type_rand;
	if [ ${?} -ne 0 ]
	then
    	echo "生成随机数失败！";
    	exit 1;
	fi;
	sort -t'	' -r -n -k6,6 ${temp}.all_data.tag_type_rand |cut -f1,2,3,4,5 > ${output_without_path};
	if [ ${?} -ne 0 ]
	then
    	echo "对随机数排序[打散obj]失败!";
    	exit 1;
	fi;

	echo -e "	打散后，输出文件为 ${output_without_path} `wc -l ${output_without_path} | cut -d ' ' -f 1` 行"
}

### 7 merge the img local path
function merge_path
{
	local path_data=$1
	local output_without_path=$2
	local output=$3
	local urls_to_download=$4
	local black_objs=$5
	awk -F '\t' -v urls_to_download="${urls_to_download}" '{
		if(FILENAME==ARGV[1]){
			blackobj[$1] = 1;
		} else if(FILENAME==ARGV[2]){
			path[$2]=$1;
		}else{
			if ($1 in black_objs) {
				next;
			}
			if($1 in path){
				# objURL    tags    fromURL path  top_freq_tag   type
				print $1"\t"$3"\t"$2"\t"path[$1]"\t"$4"\t"$5
			}else{
				print $0 > urls_to_download;
			}
		}
	}' ${black_objs} ${path_data} ${output_without_path} > ${output}

	echo -e "	合并本地路径后，输出文件为 ${output} `wc -l ${output} | cut -d ' ' -f 1` 行"
	echo -e "	还需要下载的图片，输出文件为 ${urls_to_download} `wc -l ${urls_to_download} | cut -d ' ' -f 1` 行 "
}

### 8 统计最后生成的tag数量
function stat_tags_final_objs
{
	local tag_modify=$1
	local pm_tags=$2
	local final_objs_data_without_path=$3
	local final_objs_data=$4
	local out=$5
	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			tag_modi_reverse[$2] = $1;
			tag_modi[$1] = $2;
		} else if (FILENAME == ARGV[2]) {
			pm_tag_cnt[$1] = $2;	
			last_tag_cnt_no_path[$1] = 0;
			last_tag_cnt[$1] = 0;
		} else if (FILENAME == ARGV[3]) {
			split($3, tags, ",");		
			for (i in tags) {
				tag = tags[i];
				if (tag == "服饰") {
					print;
				}
				if (tag in pm_tag_cnt) {
					last_tag_cnt_no_path[tag]++;
				} else if (tag in tag_modi_reverse) {
					last_tag_cnt_no_path[tag_modi_reverse[tag]]++;
				}
			}
		} else if (FILENAME == ARGV[4]) {
			split($2, tags, ",");		
			for (i in tags) {
				tag = tags[i];
				if (tag in pm_tag_cnt) {
					last_tag_cnt[tag]++;	
				} else if (tag in tag_modi_reverse) {
					last_tag_cnt[tag_modi_reverse[tag]]++;
				}

			}
		}
	
	} END {
		print "tag \t PM统计值 \t 包括没下载的	完全下载的	标签修改" ;
		for (tag in pm_tag_cnt) {
			print tag "\t" pm_tag_cnt[tag] "\t" last_tag_cnt_no_path[tag] "\t" last_tag_cnt[tag] "\t" (tag in tag_modi ? tag_modi[tag] : ""); 
		}
	
	}' ${tag_modify} ${pm_tags} ${final_objs_data_without_path} ${final_objs_data} >  ${out}
	
	echo -e "	统计tag个数情况输出文件 ${out}"
} 

### 9 合并tag数量变化的数据
function merge_tags_stat
{
	local tag_modify=$1
	local stat_tag=$2
	local final_tag=$3
	local out=$4
	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			tag_modi[$1] = $2;
		} else if (FILENAME == ARGV[2]) {
			pm_tag_cnt[$1] = $2;	
			total_tag_cnt[$1] = $3;
			conflict_tag_cnt[$1] = $4;
			no_tag_cnt[$1] = $5;
			tag_left_cnt[$1] = $6;
		} else if (FILENAME == ARGV[3]) {
			last_tag_cnt_no_path[$1] = $3;
			last_tag_cnt[$1] = $4;
		}
	} END {
		for (tag in pm_tag_cnt) {
			print tag "\t" pm_tag_cnt[tag] "\t" total_tag_cnt[tag] "\t" conflict_tag_cnt[tag] "\t" no_tag_cnt[tag] "\t" tag_left_cnt[tag] "\t" last_tag_cnt_no_path[tag] "\t" last_tag_cnt[tag] "\t" (tag in tag_modi ? tag_modi[tag] : ""); 
		}
	}' ${tag_modify}  ${stat_tag} ${final_tag} > ${out}
	
	echo -e "	统计tag个数情况输出文件 ${out}" 
	echo -e "	格式: tag PM评估的tag次数 去掉无tag后的统计个数 冲突的图片tag统计 没有被分类的数据tag统计 可以确定PM大类的tag统计 选择出有效数据tag统计(含未下载) 有效数据统计(完全下载) tag替换(可选)"
}


function clear_html
{
	local input=$1;
	# 非法的HTML字符集合
	local htm_char=(\&yuml\; \&yen\; \&Yacute\; \&yacute\; \&Uuml\; \&uuml\; \&uml\; \&Ugrave\; \&ugrave\; \&Ucirc\; \&ucirc\; \&Uacute\; \&uacute\; \&times\; \&THORN\; \&thorn\; \&szlig\; \&sup3\; \&sup2\; \&sup1\; \&shy\; \&sect\; \&reg\; \&raquo\; \&pound\; \&plusmn\; \&para\; \&Ouml\; \&ouml\; \&Otilde\; \&otilde\; \&Oslash\; \&oslash\; \&ordm\; \&ordf\; \&Ograve\; \&ograve\; \&Ocirc\; \&ocirc\; \&Oacute\; \&oacute\; \&Ntilde\; \&ntilde\; \&not \&nbsp\; \&middot\; \&micro\; \&macr\; \&lt\; \&laquo\; \&Iuml\; \&iuml\; \&iquest\; \&Igrave\; \&igrave\; \&iexcl\; \&Icirc\; \&icirc\; \&Iacute\; \&iacute\; \&gt\; \&frac34\; \&frac14\; \&frac12\; \&Euml\; \&euml\; \&ETH\; \&eth\; \&Egrave\; \&egrave\; \&Ecirc\; \&ecirc\; \&Eacute\; \&eacute\; \&divide\; \&deg\; \&curren\; \&copy\; \&cent\; \&cedil\; \&Ccedil\; \&ccedil\; \&brvbar\; \&Auml\; \&auml\; \&Atilde\; \&atilde\; \&Aring\; \&aring\; \&amp\; \&Agrave\; \&agrave\; \&AElig\; \&aelig\; \&acute\; \&Acirc\; \&acirc\; \&Aacute\; \&aacute\;)
	# 替换为的字符
	replace_char=""

	echo "	开始替换非法的HTML字符..."

	for htm in ${htm_char[@]}
	do
		sed -i -e "s#${htm}#${replace_char}#g" ${input}
	done

	echo "	HTML非法字符的替换完成，输出文件为 ${input}"
}
