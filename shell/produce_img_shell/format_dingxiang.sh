#!/bin/bash 

#############################################################################
# �����ļ�
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"

# ������������
dingxiang_input=${temp}".dingxiang_data_normalized";

# �������tagƵ��
tag_freq=${temp}".tag_freq_dingxiang";
dingxiang_data_tag_type=${temp}".dingxiang_data.tag_type";
data_tag_type=${temp}".all_data.tag_type";

# ͼƬ·������
path_data=${input}"/objs_local_path";

# ���ű�������ļ�
output=${temp}".final_objs_data";

# ����Ҫ���ص�ͼƬ���༴����û�е�ͼƬ
urls_to_download=${temp}".urls_to_download"

# tuhigh��404������ͼƬ����
error_404=${temp}".error_404"

#############################################################################
# �����ļ�
# ��������ѡ��һ��obj��������һ��tag�ڰ�������
dingxiang_white_tag="conf/dingxiang_tag_list";

# ������(tag��������obj������)
black_objs="./conf/obj_black_list";
black_tags="./conf/tag_black_list";

# �޸ı�ǩΪ������ǩ �� map
dingxiang_modified_tag="conf/dingxiang_tag_modified";

# ��������
type_index="conf/type_index";


#############################################################################
# ���뿪ʼ
#
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
cal_tag_freq ${temp}.dingxiang_clean_tag ${tag_freq}
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

### 4 �޸�һЩtagΪ�����tag������PM������: conf/*_tag_modified)
echo "�޸�tag..."
tag_modify ${tag_freq} ${dingxiang_modified_tag} ${dingxiang_data_tag_type} ${temp}.dingxiang_tag_modified ${tag_freq}.tag_modified
if [ ${?} -ne 0 ]
then
    echo "�޸�tagʧ��!";
    exit 1;
fi;

### 5 ȥ���������е�obj��ȥ���������е�tag������tag��Ϊ5. ���: ��ߴ�Ƶ��3�� + ����2/1��
echo "����tag������������tag��Ϊ5��...";
cat ${temp}.dingxiang_tag_modified > ${data_tag_type};
if [ ${?} -ne 0 ]
then 
    echo "�����������ͻ�ȡʧ��!";
    exit 1;
fi;
remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type} > ${data_tag_type}.filter_tags;
if [ ${?} -ne 0 ]
then
    echo "���˺�����tagʧ�ܣ�";
    exit 1;
fi;

### 6 delete * form objurl is tuhigh.com  Take care of this
remove_tuhigh ${data_tag_type}.filter_tags ${data_tag_type}.filter_tags.tmp ${error_404}
if [ ${?} -ne 0 ]
then
    echo "ɾ��tuhigh�е�404ͼƬʧ��!" 
    exit 1
fi

### 7  �����ɢobj
echo "�����ɢobj...";
rand_obj ${data_tag_type}.filter_tags ${temp} ${output}.without_path
if [ ${?} -ne 0 ]
then
    echo "�����ɢobjʧ��!";
    exit 1;
fi;

### 8 �ѱ���·���� path �ϲ���ȥ
echo "�ϲ�ͼƬ·������...";
merge_path ${path_data} ${output}.without_path  ${output}  ${urls_to_download}
if [ ${?} -ne 0 ]
then
    echo "�ϲ�ͼƬ·������ʧ�ܣ�";
    exit 1;
fi;
