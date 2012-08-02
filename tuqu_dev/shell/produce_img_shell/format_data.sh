#!/bin/bash
###################################################################################
#
#	功能: 
#		将定向数据和挖掘数据进一步格式化，生成可以直接提供给图趣的数据。
#	输入:
#		1. 	定向数据格式化后的结果 	${dingxiang_input}
#		2.	挖掘数据格式化的结果 	${mining_input}
#		3.	图片数据的本地路径		${path_data}
#	输出:
#		1.	最终可以提供给图趣上线的数据	${out}
#
###################################################################################
#	基本数据目录
# 	filename 		程序正在执行的脚本文件名
# 	temp			程序中间生成的临时文件目录
#	input			主程序的原始输入目录，手工提供的数据
#	swap			本脚本或者其他脚本的输入/输出文件目录，供脚本之间传递输入输出
#	output			主程序的输出文件
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
###################################################################################


###################################################################################
# 输入输出文件
# 挖掘和合作数据输入 
# normalize_mining_data.sh 的输出
mining_input=${swap}"/mining_data_normalized";
# normalize_dingxiang_data.sh 的输出
dingxiang_input=${swap}"/dingxiang_data_normalized";
# 图片数据输入
path_data=${input}"/objs_local_path";
# 本脚本的输出
out=${swap}"/final_objs_data";

###################################################################################
# 临时文件
# 计算出的tag频度
tag_freq=${temp}".tag_freq";
# 挖掘数据tag类型
mining_data_tag_type=${temp}".mining_data.tag_type";
# 定向数据tag类型
dingxiang_data_tag_type=${temp}".dingxiang_data.tag_type";
# 所有数据tag类型
data_tag_type=${temp}".all_data.tag_type";
# tuhigh 的404防盗链图片
error_404=${temp}".error_404"

###################################################################################
# 配置文件
# 挖掘和合作分别配置的白名单（选择一个obj中需至少一个tag在白名单）
mining_white_tag="conf/mining_tag_list";
dingxiang_white_tag="conf/dingxiang_tag_list";

# 修改标签为其它标签 即 map
mining_modified_tag="conf/mining_tag_modified";
dingxiang_modified_tag="conf/dingxiang_tag_modified";

# 类型索引配置
type_index="conf/type_index";

# obj的黑名单和tag黑名单配置
black_objs="./conf/obj_black_list";
black_tags="./conf/tag_black_list";

###################################################################################
# 代码开始

echo "开始进一步格式化数据..."

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
echo "清洗tag...";
clean_tag ${mining_input} ${temp}.mining_clean_tag;
if [ ${?} -ne 0 ]
then
    echo "清洗tag失败！";
    exit 1;
fi;
clean_tag ${dingxiang_input} ${temp}.dingxiang_clean_tag;
if [ ${?} -ne 0 ]
then
    echo "清洗tag失败！";
    exit 1;
fi;

### 2. 计算各个tag的freq
echo "计算tag频率...";
cat ${temp}.mining_clean_tag ${temp}.dingxiang_clean_tag > ${temp}.data_clean_tag;
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
}' ${temp}.data_clean_tag > ${tag_freq}
if [ ${?} -ne 0 ]
then
    echo "计算tag频率失败!";
    exit 1;
fi;

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
##print "手工："tag_freq["手工"];
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
echo "确定PM大分类...";
determine_tag_type ${temp}.dingxiang_clean_tag ${dingxiang_white_tag} ${dingxiang_data_tag_type} ${temp}.dingxiang_type_conflict;
if [ ${?} -ne 0 ]
then
    echo "确定obj所属的大分类失败！";
    exit 1;
fi;
determine_tag_type ${temp}.mining_clean_tag ${mining_white_tag} ${mining_data_tag_type} ${temp}.mining_type_conflict;

if [ ${?} -ne 0 ]
then
    echo "确定obj所属的大分类失败！";
    exit 1;
fi;

## 4.1 修改一些tag为另外的tag（根据PM的配置: conf/*_tag_modified)
awk -F '\t' -v dingxiang_out="${temp}.dingxiang_tag_modified" -v mining_out="${temp}.mining_tag_modified" '{
	if(FILENAME==ARGV[1]){
		tag_freq[$1]=$2;
	}else if(FILENAME==ARGV[2]){
		dingxiang_tag_change[$1]=$2;
		if(!($2 in tag_freq))
			tag_freq[$2]=tag_freq[$1];
	}else if(FILENAME==ARGV[3]){
		split($3,tags,",");
		tag_str="";
		for(i in tags){
			tag=tags[i];
			if(tag in dingxiang_tag_change){
				tag=dingxiang_tag_change[tag];
			}
			if(tag_str=="")
				tag_str=tag;
			else
				tag_str=tag_str","tag;
		}
		top_tag=($4 in dingxiang_tag_change)?dingxiang_tag_change[$4]:$4;
		print $1"\t"$2"\t"tag_str"\t"top_tag"\t"$5 > dingxiang_out;
	}else if(FILENAME==ARGV[4]){
		mining_tag_change[$1]=$2;
		if(!($2 in tag_freq))
			tag_freq[$2]=tag_freq[$1];
	}else{
		split($3,tags,",");
		tag_str="";
		for(i in tags){
			tag=tags[i];
			if(tag in mining_tag_change){
				tag=mining_tag_change[tag];
			}
			if(tag_str=="")
				tag_str=tag;
			else
				tag_str=tag_str","tag;
		}
		top_tag=($4 in mining_tag_change)?mining_tag_change[$4]:$4;
		print $1"\t"$2"\t"tag_str"\t"top_tag"\t"$5 > mining_out;
	}
}END{
	for(tag in tag_freq){
		print tag"\t"tag_freq[tag];
	}
}' ${tag_freq} ${dingxiang_modified_tag} ${dingxiang_data_tag_type} ${mining_modified_tag} ${mining_data_tag_type} > ${tag_freq}.tag_modified


### 5 去掉黑名单中的obj，去掉黑名单中的tag，限制tag数为5. 组成: 最高词频的3个 + 类型2/1个

echo "过滤tag黑名单，限制tag数为5个...";
cat ${temp}.dingxiang_tag_modified ${temp}.mining_tag_modified > ${data_tag_type};
if [ ${?} -ne 0 ]
then 
    echo "合并定向合作数据和挖掘数据失败！";
    exit 1;
fi;

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
		if ($5==0) {
		}
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
}' ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type} > ${data_tag_type}.filter_tags;

if [ ${?} -ne 0 ]
then
    echo "过滤黑名单tag失败！";
    exit 1;
fi;

echo "随机打散obj...";
###  随机打散obj
awk -F '\t' '{
    print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"rand();
}' ${data_tag_type}.filter_tags >${temp}.all_data.tag_type_rand;
if [ ${?} -ne 0 ]
then
    echo "生成随机数失败！";
    exit 1;
fi;
sort -t'	' -r -n -k6,6 ${temp}.all_data.tag_type_rand |cut -f1,2,3,4,5 > ${out}.without_path;
if [ ${?} -ne 0 ]
then
    echo "对随机数排序[打散obj]失败!";
    exit 1;
fi;

echo "合并图片路径数据...";
### 把本地路径合 path 合并进去
awk -F '\t' -v urls_to_download="${temp}.urls_to_download" '{
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
}' ${path_data} ${out}.without_path > ${out}
if [ ${?} -ne 0 ]
then
    echo "合并图片路径数据失败！";
    exit 1;
fi;

echo -e "进一步格式化数据完成. 输出文件为 ${out}"
