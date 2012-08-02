#!/bin/bash
### ��ʽ�����ݣ������ھ����ݺͺ������ݣ�
# �ھ�ͺ����������� 
# normalize_mining_data.sh �����
mining_input= "data/mining_data_normalized";
#mining_input="data/temp/mine_tag_data.size_tag_filter";
# normalize_dingxiang_data.sh �����
dingxiang_input="data/dingxiang_data_normalized";

# �ھ�ͺ����ֱ����õİ�������ѡ��һ��obj��������һ��tag�ڰ�������
mining_white_tag="conf/mining_tag_list";
dingxiang_white_tag="conf/dingxiang_tag_list";

# �޸ı�ǩΪ������ǩ �� map
mining_modified_tag="conf/mining_tag_modified";
dingxiang_modified_tag="conf/dingxiang_tag_modified";

# ��������
type_index="conf/type_index";

# �������tagƵ��
tag_freq="data/tag_freq";
mining_data_tag_type="./data/mining_data.tag_type";
dingxiang_data_tag_type="./data/dingxiang_data.tag_type";
data_tag_type="./data/all_data.tag_type";

black_objs="./conf/obj_black_list";
black_tags="./conf/tag_black_list";

# ͼƬ·������
path_data="./data/objs_local_path";
output="./data/final_objs_data";
temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`

error_404="./data/error_404"

### 1. ��ϴ tag��ȥ��û��tag ��obj����tag�еĿո��滻Ϊ_����,�ָ�tag,ȥ���ظ���tag,ȥ����tag
echo "��ϴtag...";
clean_tag ${dingxiang_input} ${temp}.dingxiang_clean_tag;
if [ ${?} -ne 0 ]
then
    echo "��ϴtagʧ�ܣ�";
    exit 1;
fi;

### 2. �������tag��freq
echo "����tagƵ��...";
cal_tag_freq ${temp}.dingxiang_clean_tag ${tag_freq}.dingxiang
if [ ${?} -ne 0 ]
then
    echo "����tagƵ��ʧ��!";
    exit 1;
fi;

### 3. ȷ��pm�Ĵ����
echo "ȷ��PM�����...";
determine_tag_type ${temp}.dingxiang_clean_tag ${dingxiang_white_tag} ${dingxiang_data_tag_type} ${temp}.dingxiang_type_conflict;
if [ ${?} -ne 0 ]
then
    echo "ȷ��obj�����Ĵ����ʧ�ܣ�";
    exit 1;
fi;

## 4 �޸�һЩtagΪ�����tag������PM������: conf/*_tag_modified)
echo "�޸�tag..."
tag_modify ${tag_freq} ${dingxiang_modified_tag} ${dingxiang_data_tag_type} ${temp}.dingxiang_tag_modified ${tag_freq}.tag_modified
if [ ${?} -ne 0 ]
then
    echo "�޸�tagʧ��!";
    exit 1;
fi;

### 5 ȥ���������е�obj��ȥ���������е�tag������tag��Ϊ5. ���: ��ߴ�Ƶ��3�� + ����2/1��
echo "����tag������������tag��Ϊ5��...";
cat ${temp}.dingxiang_tag_modified ${temp}.mining_tag_modified > ${data_tag_type};
if [ ${?} -ne 0 ]
then 
    echo "�ϲ�����������ݺ��ھ�����ʧ�ܣ�";
    exit 1;
fi;

remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type} > ${data_tag_type}.filter_tags;

if [ ${?} -ne 0 ]
then
    echo "���˺�����tagʧ�ܣ�";
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

echo "�����ɢobj...";
#  �����ɢobj
awk -F '\t' '{
    print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"rand();
}' ${data_tag_type}.filter_tags >${temp}.all_data.tag_type_rand;
if [ ${?} -ne 0 ]
then
    echo "���������ʧ�ܣ�";
    exit 1;
fi;
sort -t'	' -r -n -k6,6 ${temp}.all_data.tag_type_rand |cut -f1,2,3,4,5 > ${output}.without_path;
if [ ${?} -ne 0 ]
then
    echo "�����������[��ɢobj]ʧ��!";
    exit 1;
fi;

echo "�ϲ�ͼƬ·������...";
# �ѱ���·���� path �ϲ���ȥ
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
    echo "�ϲ�ͼƬ·������ʧ�ܣ�";
    exit 1;
fi;
