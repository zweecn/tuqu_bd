#!/bin/bash 

function format_data
{
	if [ $# -ne 1 ];then
		echo "��������������ȷ�Ĳ���������1."
		exit 1
	fi
	prefix=$1
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

	filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
	temp="./data/temp/"${filename}.${prefix}
	input="./data/input"
	swap="./data/swap/"${prefix}
	output="./data/output"
	today=`date +%Y%m%d`
###################################################################################

#############################################################################
# �����ļ�
# ͼƬ·������
	path_data=${input}"/objs_local_path"

# ������������
	in=${swap}"_data_normalized"

# ���ű�������ļ�
	out=${swap}"_final_objs_data"

#############################################################################
# ��ʱ�ļ�
# �������tagƵ��
	tag_freq=${temp}".tag_freq"
	data_tag_type=${temp}".tag_type"

# ����Ҫ���ص�ͼƬ���༴����û�е�ͼƬ
	urls_to_download=${temp}".urls_to_download"

#############################################################################
# �����ļ�
# ��������ѡ��һ��obj��������һ��tag�ڰ�������
	white_tag="conf/"${prefix}"_tag_list"

# ������(tag��������obj������)
	black_objs="./conf/obj_black_list"
	black_tags="./conf/tag_black_list"

# �޸ı�ǩΪ������ǩ �� map
	modified_tag="conf/"${prefix}"_tag_modified"
	
# ��������
	type_index="conf/type_index"

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

### 2. �������tag��freq
	echo "2. ����tagƵ��...";
	cal_tag_freq ${temp}.clean_tag ${tag_freq}
	if [ ${?} -ne 0 ]
	then
		echo "����tagƵ��ʧ��!";
		exit 1;
	fi;

### 3. ȷ��pm�Ĵ����
	echo "3. ȷ��PM�����...";
	determine_tag_type ${temp}.clean_tag ${white_tag} ${data_tag_type} ${temp}.type_conflict ${temp}.no_type
	if [ ${?} -ne 0 ]
	then
		echo "ȷ��obj�����Ĵ����ʧ�ܣ�";
		exit 1;
	fi;

### 4 �޸�һЩtagΪ�����tag������PM������: conf/*_tag_modified)
	echo "4. �޸�tag..."
#	tag_modify ${tag_freq} ${modified_tag} ${data_tag_type} ${temp}.tag_modified ${tag_freq}.tag_modified
	tag_modify ${tag_freq} ${modified_tag} ${data_tag_type} ${data_tag_type}.tag_modified ${tag_freq}.tag_modified
	if [ ${?} -ne 0 ]
	then
		echo "�޸�tagʧ��!";
		exit 1;
	fi;

### 5 ȥ���������е�obj��ȥ���������е�tag������tag��Ϊ5. ���: ��ߴ�Ƶ��3�� + ����2/1��
	echo "5. ����tag������������tag��Ϊ5��...";
#	remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type} ${data_tag_type}.filter_tags;
	remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type}.tag_modified ${data_tag_type}.filter_tags;
	if [ ${?} -ne 0 ]
	then
		echo "���˺�����tagʧ�ܣ�";
		exit 1;
	fi;

### **.dingxiang �ڷ�����Ϣ������ÿ��վ����Ϣ, ����ÿ�������Ҫ��ͼƬ�����������ļ
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
	merge_path ${path_data} ${out}.without_path  ${out}  ${urls_to_download}
	if [ ${?} -ne 0 ]
	then
		echo "�ϲ�ͼƬ·������ʧ�ܣ�";
		exit 1;
	fi;

	echo -e "��ʽ��${suffix}������ɣ��������Ϊ ${out}"
}
