#!/bin/bash 

function format_data
{
	if [ $# -ne 1 ];then
		echo "��������������ȷ�Ĳ���������1."
		exit 1
	fi
	local prefix=$1
	if [ $prefix != "dingxiang" -a $prefix != "mine" ]; then
		echo "��������. ��ȷ�Ĳ���ֻ����1��: dingxiang ���� mine ."
		exit 1
	fi

###################################################################################
#	��������Ŀ¼
# 	filename 		��������ִ�еĽű��ļ���
# 	temp			�����м����ɵ���ʱ�ļ�Ŀ¼
#	input			�������ԭʼ����Ŀ¼���ֹ��ṩ������
#	swap			���ű����������ű�������/����ļ�Ŀ¼�����ű�֮�䴫���������
#	output			�����������ļ�
#	today			��������ڣ���ʽ�������� "20120802"

	local filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
	local temp="./data/temp/"${filename}.${prefix}
	local input="./data/input"
	local swap="./data/swap/"${prefix}
	local output="./data/output"
	local today=`date +%Y%m%d`
###################################################################################

#############################################################################
# �����ļ�
# ͼƬ·������
	local path_data=${input}"/objs_local_path"

# ������������
	local in=${swap}"_data_normalized"

# ���ű�������ļ�
	local out=${swap}"_final_objs_data"

# ���ű�ͳ�Ƶ�tag�������ļ� 
	local out_tag_stat=${swap}"_tag_stat"
	
#############################################################################
# ��ʱ�ļ�
# �������tagƵ��
	local tag_freq=${temp}".tag_freq"
	local data_tag_type=${temp}".tag_type"

# ����Ҫ���ص�ͼƬ���༴����û�е�ͼƬ
	local urls_to_download=${temp}".urls_to_download"

#############################################################################
# �����ļ�
# ��������ѡ��һ��obj��������һ��tag�ڰ�������
	local white_tag="./conf/"${prefix}"_tag_list"

# ������(tag��������obj������)
	local black_objs="./conf/obj_black_list"
	local black_tags="./conf/tag_black_list"

# �޸ı�ǩΪ������ǩ �� map
	local modified_tag="./conf/"${prefix}"_tag_modified"
	local pre_modi_tag="./conf/pre_modi_tag"

	local clear_char="./conf/clear_char"
# ��������
	local type_index="./conf/type_index"

# PM ͳ�Ƶ�tagֵ
	local pm_tags="./conf/"${prefix}"_pm_tag_count"

#############################################################################
# ���뿪ʼ
#

	echo -e "��ʼ��ʽ������ ${prefix} ..."
	echo "source format_func.sh ..."
	source ./shell/produce_img_shell/format_func.sh
	if [ ${?} -ne 0 ]
	then
		echo "source failed."
		exit 1
	fi

### 1. ��ϴ tag��ȥ��û��tag ��obj����tag�еĿո��滻Ϊ_����,�ָ�tag,ȥ���ظ���tag,ȥ����tag
	echo "1. ��ϴtag...";
	clean_tag ${in} ${temp}.clean_tag ${temp}.no_tag;
	if [ ${?} -ne 0 ]
	then
		echo "��ϴtagʧ�ܣ�";
		exit 1;
	fi;

### 2. �޸�һЩtagΪ�����tag������PM������: conf/*_tag_modified)
	echo "2. �޸�tag..."
	pre_tag_modify ${pre_modi_tag} ${clear_char} ${temp}.clean_tag ${temp}.modi_tags
	if [ ${?} -ne 0 ]
	then
		echo "�޸�tagʧ�ܣ�";
		exit 1;
	fi;

### 3. �������tag��freq
	echo "3. ����tagƵ��...";
	cal_tag_freq ${temp}.modi_tags ${tag_freq}
	if [ ${?} -ne 0 ]
	then
		echo "����tagƵ��ʧ��!";
		exit 1;
	fi;

### 4. ȷ��pm�Ĵ����
	echo "4. ȷ��PM�����...";
	determine_tag_type ${temp}.modi_tags ${white_tag} ${data_tag_type} ${temp}.type_conflict ${temp}.no_type ${pm_tags} ${temp}.stat_tag
	if [ ${?} -ne 0 ]
	then
		echo "ȷ��obj�����Ĵ����ʧ�ܣ�";
		exit 1;
	fi;

### 5 ȥ���������е�obj��ȥ���������е�tag������tag��Ϊ5. ���: ��ߴ�Ƶ��3�� + ����2/1��
	echo "5. ����tag������������tag��Ϊ5��...";
#	remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type}.tag_modified ${data_tag_type}.filter_tags ${white_tag}
	remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq} ${data_tag_type} ${data_tag_type}.filter_tags ${white_tag}
	if [ ${?} -ne 0 ]
	then
		echo "���˺�����tagʧ�ܣ�";
		exit 1;
	fi;

### **.dingxiang �ڷ�����Ϣ������ÿ��վ����Ϣ, ����ÿ�������Ҫ��ͼƬ���������
	if [ ${prefix} = "dingxiang" ]; then
		update_type_and_demand ${data_tag_type}.filter_tags ${temp}.filter_tags_tmp
	fi


### 6  �����ɢobj
	echo "6. �����ɢobj...";
	rand_obj ${data_tag_type}.filter_tags ${temp} ${out}.without_path
	if [ ${?} -ne 0 ]
	then
		echo "�����ɢobjʧ��!";
		exit 1;
	fi;

### 7 �ѱ���·���� path �ϲ���ȥ
	echo "7. �ϲ�ͼƬ·������...";
	merge_path ${path_data} ${out}.without_path  ${out}  ${urls_to_download} ${black_objs}
	if [ ${?} -ne 0 ]
	then
		echo "�ϲ�ͼƬ·������ʧ�ܣ�";
		exit 1;
	fi;
	
### 8 ͳ��tag�������
	echo "8. ͳ��tag�������..."
	stat_tags_final_objs ${modified_tag} ${pm_tags} ${out}.without_path ${out}  ${temp}.final_tag_stat
	if [ ${?} -ne 0 ]
	then
		echo "ͳ��tag����ʧ��!";
		exit 1;
	fi;

### 9 �ϲ�tag�������	
	echo "9. �ϲ�tag�������..."
	merge_tags_stat ${modified_tag} ${temp}.stat_tag ${temp}.final_tag_stat  ${out_tag_stat}
	if [ ${?} -ne 0 ]
	then
		echo "�ϲ�tagͳ�����ʧ��!";
		exit 1;
	fi;
	
	echo -e "��ʽ��${suffix}������ɣ��������Ϊ ${out}"
}

