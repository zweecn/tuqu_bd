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
    func_input=$1;
    func_output=$2;
    awk -F '\t' '{
		# objURL    fromURL     tags
		if($1=="" || $2=="" || $3==""){
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
}

### 2. 计算tag频率
function cal_tag_freq
{
	data_clean_tag=$1
	tag_freq=$2
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
}

### 3. 确定pm的大分类
function determine_tag_type
{
    func_input=$1;
    func_tag_type_conf=$2;
    func_output=$3;
    func_conflict_output=$4;
    awk -F '\t' -v conflict_output="${func_conflict_output}"  '{
        if(FILENAME==ARGV[1]){
            tag_type[$1]=$2;
        }else if(FILENAME==ARGV[2]){
            tag_freq[$1]=$2;
        }else{
##			print "手工："tag_freq["手工"];
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
            if(top_freq_tag!=""){
                # objURL    fromURL tags    top_freq_tag    type
                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag];
            }
            if(conflict_mark==1){ #前后数据有10W条冲突的,有必要挖掘出来
                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag] > conflict_output
            }
        }
    }' ${func_tag_type_conf} ${tag_freq}  ${func_input} > ${func_output}
}


## 4 修改一些tag为另外的tag（根据PM的配置: conf/*_tag_modified)
function tag_modify
{
	tag_freq=$1
	suffix_modified_tag=$2
	suffix_data_tag_type=$3
	tag_modify_out=$4
	tag_freq_modified=$5
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
		}END{
		for(tag in tag_freq){
			print tag"\t"tag_freq[tag];
		}
	}' ${tag_freq} ${suffix_modified_tag} ${suffix_data_tag_type} > ${tag_freq_modified}
}


### 5 去掉黑名单中的obj，去掉黑名单中的tag，限制tag数为5. 组成: 最高词频的3个 + 类型2/1个
function remove_black_tag 
{
	black_objs=$1
	black_tags=$2
	type_index=$3
	tag_freq_modified=$4
	data_tag_type=$5
	data_tag_type_filter_tags=$6
	
	awk -F '\t' '{
		if(FILENAME==ARGV[1]){
			obj_black[$1]=1;
		}else if(FILENAME==ARGV[2]){
			tag_black[$1]=1;
		}else if(FILENAME==ARGV[3]){
			type_index[$2]=$1;
		}else if(FILENAME==ARGV[4]){
			tag_freq[$1]=$2;
		}else{
			if($1 in obj_black){
				next;
			}
			split($3,tags,",");
			top_freq_tag=$4;
			type=type_index[$5];
			tag1="";
			tag2="";
			tag3="";
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
			delete final_tags;
			if(!(top_freq_tag in tag_black)){
				final_tags[top_freq_tag];
			}
			## 把 时尚搭配服饰 拆成  时尚搭配 和 服饰
			if($5==4){
				final_tags["时尚搭配"];
				final_tags["服饰"];
			}else if($5==2){   ## 把 风景/旅行 拆成 风景 和 旅行
				final_tags["风景"];
				final_tags["旅行"];
			}else{
				final_tags[type_index[$5]];
			}
			if(tag1!="")
				final_tags[tag1];
			if(tag2!="")
				final_tags[tag2];
			if(tag3!="")
				final_tags[tag3];
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
	}' ${black_objs} ${black_tags} ${type_index} ${tag_freq_modified} ${data_tag_type} > ${data_tag_type_filter_tags};
}


### 6  随机打散obj
function rand_obj
{
	data_tag_type_filter_tags=$1
	temp=$2
	output_without_path=$3
	awk -F '\t' '{
    	print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"rand();
	}' ${data_tag_type_filter_tags} >${temp}.all_data.tag_type_rand;
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
}

### 7 merge the img local path
function merge_path
{
	path_data=$1
	output_without_path=$2
	output=$3
	urls_to_download=$4
	awk -F '\t' -v urls_to_download="${urls_to_download}" '{
		if(FILENAME==ARGV[1]){
			path[$2]=$1;
		}else{
			if($1 in path){
				# objURL    tags    fromURL path  top_freq_tag   type
				print $1"\t"$3"\t"$2"\t"path[$1]"\t"$4"\t"$5
			}else{
				print $0 > urls_to_download;
			}
		}
	}' ${path_data} ${output_without_path} > ${output}
}
