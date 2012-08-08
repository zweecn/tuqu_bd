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
function determine_tag_type
{
	echo -e "	确定PM大分类的输入文件是 $1 `wc -l $1 | cut -d ' ' -f 1` 行"
   	local func_input=$1;
   	local func_tag_type_conf=$2;
    local func_output=$3;
    local func_conflict_output=$4;
	local no_type_out=$5;
    awk -F '\t' -v conflict_output="${func_conflict_output}" -v no_out="${no_type_out}" '{
        if(FILENAME==ARGV[1]){
            tag_type[$1]=$2;
        }else if(FILENAME==ARGV[2]){
            tag_freq[$1]=$2;
        }else{
            split($3,tags,",");
			
			
#######################################################################################################
# 修改后的策略 开始
			delete type_cnt;
			for (i in tags) {
				tag = tags[i];
				if (tag in tag_type) {
					type = tag_type[tag];
					type_cnt[type]++;
				} else {
#					print tag > no_out;
				}
			}
			for (t in type_cnt) {
				if (top_type == "") {
					top_type = t;
				} else {
					if (type_cnt[top_type] < type_cnt[t]) {
						top_type = t;
					}
				}
			}
		
# 			所有的tag都没出现在tag列表中，被判定为无类型
			if (top_type == "") {
				print $0 > no_out;	
			} else {
				for (i in tags) {
					tag = tags[i];
					if (tag_type[tag] == tag_type[top_type]) {
						if (top_type_tag == "") {
							top_type_tag = tag;
						} else {
							if (tag_freq[top_type_tag] < tag_freq[tag]) {
								top_type_tag = tag; 
							}
						}
					}
				}
                print $1"\t"$2"\t"$3"\t"top_type_tag"\t"top_type;
			}
# 修改后的策略 结束
#######################################################################################################
# 原来的策略 开始
#			 delete types;
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
# 
# 原来的策略 结束
#####################
#            if(top_freq_tag!=""){
#                # objURL    fromURL tags    top_freq_tag    type
#                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag];
#            } 
#			 if(conflict_mark==1){ #前后数据有10W条冲突的,有必要挖掘出来
#                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag] > conflict_output;
#			 }
#######################################################################################################

        }
    }' ${func_tag_type_conf} ${tag_freq}  ${func_input} > ${func_output}
	echo -e "	确定PM大分类后，输出文件为 ${func_output} `wc -l ${func_output} | cut -d' ' -f 1` 行"
#	echo -e	"	冲突文件为 ${func_conflict_output} `wc -l ${func_conflict_output} | cut -d' ' -f 1` 行"
	echo -e	"	没被分类的为 ${no_type_out} `wc -l ${no_type_out} | cut -d' ' -f 1` 行"
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
#			
######################################################################			
#	修改策略前的版本
#			
#			type=type_index[$5];
#			tag1="";
#			tag2="";
#			tag3="";
#			tag4="";
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
#					}else if(tag4=="" || tag_freq[tag]>tag_freq[tag4]){
#						tag4=tag;	
#					}
#				}
#			}
#			delete final_tags;
#			if(!(top_freq_tag in tag_black)){
#				final_tags[top_freq_tag];
#			}
#
######################################################################			
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
			
			if($5!=0){
				final_tags[type_index[$5]];
			}
			
			if(tag1!="")
				final_tags[tag1];
			if(tag2!="")
				final_tags[tag2];
			if(tag3!="")
				final_tags[tag3];
#			if(tag4!="")
#				final_tags[tag4];
			tag_str="";
			for( tag in final_tags){
				if(tag_str=="")
					tag_str=tag;
				else
					tag_str=tag_str","tag;
			}
			# objURL    fromURL     tags    top_freq_tag    type
			print $1"\t"$2"\t"tag_str"\t"top_freq_tag"\t"type;
		}
	}' ${black_objs} ${black_tags} ${type_index} ${tag_type_list} ${tag_freq_modified} ${data_tag_type} > ${data_tag_type_filter_tags};
	echo -e "	去掉黑名单后输出文件为 ${data_tag_type_filter_tags} `wc -l ${data_tag_type_filter_tags} | cut -d' ' -f 1` 行"
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
