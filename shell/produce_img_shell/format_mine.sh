#!/bin/bash 

#############################################################################
# 数据文件
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"

# 图片路径数据
path_data=${input}"/objs_local_path";

# 定向数据输入
mine_input=${swap}"/mining_data_normalized";

# 本脚本的输出文件
output=${swap}"/final_objs_data.mine";

# 计算出的tag频度
tag_freq=${temp}".tag_freq_mine";
mine_data_tag_type=${temp}".mine_data.tag_type";
data_tag_type=${temp}".all_data.tag_type";

# 还需要下载的图片，亦即本地没有的图片
urls_to_download=${temp}".urls_to_download"

# tuhigh的404防盗链图片过滤
error_404=${temp}".error_404"

#############################################################################
# 配置文件
# 白名单（选择一个obj中需至少一个tag在白名单）
mine_white_tag="conf/mine_tag_list";

# 黑名单(tag黑名单和obj黑名单)
black_objs="./conf/obj_black_list";
black_tags="./conf/tag_black_list";

# 修改标签为其它标签 即 map
mine_modified_tag="conf/mine_tag_modified";

# 类型索引
type_index="conf/type_index";


#############################################################################
# 代码开始
#
### 1. 清洗 tag，去掉没有tag 的obj，把tag中的空格替换为_，用,分割tag,去掉重复的tag,去掉空tag
echo "清洗tag...";
clean_tag ${mine_input} ${temp}.mine_clean_tag;
if [ ${?} -ne 0 ]
then
    echo "清洗tag失败！";
    exit 1;
fi;

### 2. 计算各个tag的freq
echo "计算tag频率...";
cal_tag_freq ${temp}.mine_clean_tag ${tag_freq}
if [ ${?} -ne 0 ]
then
    echo "计算tag频率失败!";
    exit 1;
fi;

### 3. 确定pm的大分类
echo "确定PM大分类...";
determine_tag_type ${temp}.mine_clean_tag ${mine_white_tag} ${mine_data_tag_type} ${temp}.mine_type_conflict;
if [ ${?} -ne 0 ]
then
    echo "确定obj所属的大分类失败！";
    exit 1;
fi;

### 4 修改一些tag为另外的tag（根据PM的配置: conf/*_tag_modified)
echo "修改tag..."
tag_modify ${tag_freq} ${mine_modified_tag} ${mine_data_tag_type} ${temp}.mine_tag_modified ${tag_freq}.tag_modified
if [ ${?} -ne 0 ]
then
    echo "修改tag失败!";
    exit 1;
fi;

### 5 去掉黑名单中的obj，去掉黑名单中的tag，限制tag数为5. 组成: 最高词频的3个 + 类型2/1个
echo "过滤tag黑名单，限制tag数为5个...";
cat ${temp}.mine_tag_modified > ${data_tag_type};
if [ ${?} -ne 0 ]
then 
    echo "定向数据类型获取失败!";
    exit 1;
fi;
remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type} > ${data_tag_type}.filter_tags;
if [ ${?} -ne 0 ]
then
    echo "过滤黑名单tag失败！";
    exit 1;
fi;

### 6 delete * form objurl is tuhigh.com  Take care of this
remove_tuhigh ${data_tag_type}.filter_tags ${data_tag_type}.filter_tags.tmp ${error_404}
if [ ${?} -ne 0 ]
then
    echo "删除tuhigh中的404图片失败!" 
    exit 1
fi

### 7  随机打散obj
echo "随机打散obj...";
rand_obj ${data_tag_type}.filter_tags ${temp} ${output}.without_path
if [ ${?} -ne 0 ]
then
    echo "随机打散obj失败!";
    exit 1;
fi;

### 8 把本地路径合 path 合并进去
echo "合并图片路径数据...";
merge_path ${path_data} ${output}.without_path  ${output}  ${urls_to_download}
if [ ${?} -ne 0 ]
then
    echo "合并图片路径数据失败！";
    exit 1;
fi;
