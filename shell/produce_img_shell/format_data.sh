#!/bin/bash 

function format_data
{
	if [ $# -ne 1 ];then
		echo "参数个数错误，正确的参数个数是1."
		exit 1
	fi
	local prefix=$1
	if [ $prefix != "dingxiang" -a $prefix != "mine" ]; then
		echo "参数错误. 正确的参数只能是1个: dingxiang 或者 mine ."
		exit 1
	fi

###################################################################################
#	基本数据目录
# 	filename 		程序正在执行的脚本文件名
# 	temp			程序中间生成的临时文件目录
#	input			主程序的原始输入目录，手工提供的数据
#	swap			本脚本或者其他脚本的输入/输出文件目录，供脚本之间传递输入输出
#	output			主程序的输出文件
#	today			今天的日期，格式是类似于 "20120802"

	local filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
	local temp="./data/temp/"${filename}.${prefix}
	local input="./data/input"
	local swap="./data/swap/"${prefix}
	local output="./data/output"
	local today=`date +%Y%m%d`
###################################################################################

#############################################################################
# 数据文件
# 图片路径数据
	local path_data=${input}"/objs_local_path"

# 定向数据输入
	local in=${swap}"_data_normalized"

# 本脚本的输出文件
	local out=${swap}"_final_objs_data"
	local out_without_path=${out}.without_path

# 本脚本统计的tag情况输出文件 
	local out_tag_stat=${swap}"_tag_stat"
		
#############################################################################
# 临时文件
# 计算出的tag频度
	local tag_freq=${temp}".tag_freq"
	local data_tag_type=${temp}".tag_type"

# 还需要下载的图片，亦即本地没有的图片
	local urls_to_download=${temp}".urls_to_download"

	local tag_cleaned=${temp}.clean_tag 
	local no_tag=${temp}.no_tag	
	local tag_modified=${temp}.tag_modified
	local type_conflict=${temp}.type_conflict
	local no_type=${temp}.no_type
	local stat_tag_res=${temp}.stat_tag
	local final_tag_stat=${temp}.final_stat_tag
	local filter_tags=${temp}.filter_tags

#############################################################################
# 配置文件
# 白名单（选择一个obj中需至少一个tag在白名单）
	local white_tag="./conf/"${prefix}"_tag_list"

# 黑名单(tag黑名单和obj黑名单)
	local black_objs="./conf/obj_black_list"
	local black_tags="./conf/tag_black_list"

# 修改标签为其它标签 即 map
	local modified_tag="./conf/tag_modified"

	local clear_char="./conf/clear_char"
# 类型索引
	local type_index="./conf/type_index"

# PM 统计的tag值
	local pm_tags="./conf/"${prefix}"_pm_tag_count"

#############################################################################
# 代码开始
#
	echo -e "[format_data.sh] 开始格式化 ${prefix}..."
	echo "	source format_func.sh ..."
	source ./shell/produce_img_shell/format_func.sh
	if [ ${?} -ne 0 ]
	then
		echo "source failed."
		exit 1
	fi

### 1. 清洗 tag，去掉没有tag 的obj，把tag中的空格替换为_，用,分割tag,去掉重复的tag,去掉空tag
	echo "1. 清洗tag..."
	clean_tag ${in} ${tag_cleaned} ${no_tag}
	if [ ${?} -ne 0 ]
	then
		echo "清洗tag失败！";
		exit 1;
	fi

### 2. 修改一些tag为另外的tag（根据PM的配置: conf/*_tag_modified)
	echo "2. 修改tag..."
	pre_tag_modify ${modified_tag} ${clear_char} ${tag_cleaned} ${tag_modified}
	if [ ${?} -ne 0 ]
	then
		echo "修改tag失败！";
		exit 1;
	fi;

### 3. 计算各个tag的freq
	echo "3. 计算tag频率...";
	cal_tag_freq ${tag_modified} ${tag_freq}
	if [ ${?} -ne 0 ]
	then
		echo "计算tag频率失败!";
		exit 1;
	fi;

### 4. 确定pm的大分类
	echo "4. 确定PM大分类...";
	determine_tag_type ${tag_modified} ${white_tag} ${data_tag_type} ${type_conflict} ${no_type} ${pm_tags} ${stat_tag_res}
	if [ ${?} -ne 0 ]
	then
		echo "确定obj所属的大分类失败！";
		exit 1;
	fi;

### 5 去掉黑名单中的obj，去掉黑名单中的tag，限制tag数为5. 组成: 决定分类的tag有1个 + 次最高词频的3个 + 类型作为tag有1个
	echo "5. 过滤tag黑名单，限制tag数为5个...";
	remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq} ${data_tag_type} ${filter_tags} ${white_tag}
	if [ ${?} -ne 0 ]
	then
		echo "过滤黑名单tag失败！";
		exit 1;
	fi;

### **.dingxiang 在分类信息后增加每个站点信息, 更新每个类别需要的图片数量的配�
	if [ ${prefix} = "dingxiang" ]; then
		update_type_and_demand ${filter_tags} 
	fi


### 6  随机打散obj
	echo "6. 随机打散obj...";
	rand_obj ${filter_tags} ${temp} ${out_without_path}
	if [ ${?} -ne 0 ]
	then
		echo "随机打散obj失败!";
		exit 1;
	fi;

### 7 把本地路径合 path 合并进去
	echo "7. 合并图片路径数据...";
	merge_path ${path_data} ${out_without_path}  ${out}  ${urls_to_download} ${black_objs}
	if [ ${?} -ne 0 ]
	then
		echo "合并图片路径数据失败！";
		exit 1;
	fi;
	
### 8 统计tag个数情况
	echo "8. 统计tag个数情况..."
	stat_tags_final_objs ${modified_tag} ${pm_tags} ${out_without_path} ${out}  ${final_tag_stat}
	if [ ${?} -ne 0 ]
	then
		echo "统计tag个数失败!";
		exit 1;
	fi;

### 9 合并tag个数情况	
	echo "9. 合并tag个数情况..."
	merge_tags_stat ${modified_tag} ${stat_tag_res} ${final_tag_stat} ${out_tag_stat}
	if [ ${?} -ne 0 ]
	then
		echo "合并tag统计情况失败!";
		exit 1;
	fi;
	
	echo -e "[输出]	格式化${suffix}数据完成，输出数据为 ${out}"
}

