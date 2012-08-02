#!/bin/bash
### 格式化数据（包括挖掘数据和合作数据）
# 挖掘和合作数据输入 
# normalize_mining_data.sh 的输出
mining_input= "data/mining_data_normalized";
#mining_input="data/temp/mine_tag_data.size_tag_filter";
# normalize_dingxiang_data.sh 的输出
dingxiang_input="data/dingxiang_data_normalized";

# 挖掘和合作分别配置的白名单（选择一个obj中需至少一个tag在白名单）
mining_white_tag="conf/mining_tag_list";
dingxiang_white_tag="conf/dingxiang_tag_list";

# 修改标签为其它标签 即 map
mining_modified_tag="conf/mining_tag_modified";
dingxiang_modified_tag="conf/dingxiang_tag_modified";

# 类型索引
type_index="conf/type_index";

# 计算出的tag频度
tag_freq="data/tag_freq";
mining_data_tag_type="./data/mining_data.tag_type";
dingxiang_data_tag_type="./data/dingxiang_data.tag_type";
data_tag_type="./data/all_data.tag_type";

black_objs="./conf/obj_black_list";
black_tags="./conf/tag_black_list";

# 图片路径数据
path_data="./data/objs_local_path";
output="./data/final_objs_data";
temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`

error_404="./data/error_404"

### 1. 清洗 tag，去掉没有tag 的obj，把tag中的空格替换为_，用,分割tag,去掉重复的tag,去掉空tag
echo "清洗tag...";
clean_tag ${dingxiang_input} ${temp}.dingxiang_clean_tag;
if [ ${?} -ne 0 ]
then
    echo "清洗tag失败！";
    exit 1;
fi;

### 2. 计算各个tag的freq
echo "计算tag频率...";
cal_tag_freq ${temp}.dingxiang_clean_tag ${tag_freq}.dingxiang
if [ ${?} -ne 0 ]
then
    echo "计算tag频率失败!";
    exit 1;
fi;

### 3. 确定pm的大分类
echo "确定PM大分类...";
determine_tag_type ${temp}.dingxiang_clean_tag ${dingxiang_white_tag} ${dingxiang_data_tag_type} ${temp}.dingxiang_type_conflict;
if [ ${?} -ne 0 ]
then
    echo "确定obj所属的大分类失败！";
    exit 1;
fi;

## 4 修改一些tag为另外的tag（根据PM的配置: conf/*_tag_modified)
echo "修改tag..."
tag_modify ${tag_freq} ${dingxiang_modified_tag} ${dingxiang_data_tag_type} ${temp}.dingxiang_tag_modified ${tag_freq}.tag_modified
if [ ${?} -ne 0 ]
then
    echo "修改tag失败!";
    exit 1;
fi;

### 5 去掉黑名单中的obj，去掉黑名单中的tag，限制tag数为5. 组成: 最高词频的3个 + 类型2/1个
echo "过滤tag黑名单，限制tag数为5个...";
cat ${temp}.dingxiang_tag_modified ${temp}.mining_tag_modified > ${data_tag_type};
if [ ${?} -ne 0 ]
then 
    echo "合并定向合作数据和挖掘数据失败！";
    exit 1;
fi;

remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type} > ${data_tag_type}.filter_tags;

if [ ${?} -ne 0 ]
then
    echo "过滤黑名单tag失败！";
    exit 1;
fi;

# delete * form objurl is tuhigh.com
function remove_tuhigh {
	file=$1;
	out=$2;
	awk -F'\t' ' {
		if (index($1, "tuhigh.com")) {
			print $0 > "./data/error_404";
		} else {
			print $0;
		}
	}' ${file} > ${out} 
}
remove_tuhigh ${data_tag_type}.filter_tags ${data_tag_type}.filter_tags.tmp
mv ${data_tag_type}.filter_tags ${data_tag_type}.filter_tags.bak
mv ${data_tag_type}.filter_tags.tmp ${data_tag_type}.filter_tags

echo "随机打散obj...";
#  随机打散obj
awk -F '\t' '{
    print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"rand();
}' ${data_tag_type}.filter_tags >${temp}.all_data.tag_type_rand;
if [ ${?} -ne 0 ]
then
    echo "生成随机数失败！";
    exit 1;
fi;
sort -t'	' -r -n -k6,6 ${temp}.all_data.tag_type_rand |cut -f1,2,3,4,5 > ${output}.without_path;
if [ ${?} -ne 0 ]
then
    echo "对随机数排序[打散obj]失败!";
    exit 1;
fi;

echo "合并图片路径数据...";
# 把本地路径合 path 合并进去
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
}' ${path_data} ${output}.without_path > ${output}
if [ ${?} -ne 0 ]
then
    echo "合并图片路径数据失败！";
    exit 1;
fi;
