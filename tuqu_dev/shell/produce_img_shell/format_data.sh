#!/bin/bash
###################################################################################
#
#	����: 
#		���������ݺ��ھ����ݽ�һ����ʽ�������ɿ���ֱ���ṩ��ͼȤ�����ݡ�
#	����:
#		1. 	�������ݸ�ʽ����Ľ�� 	${dingxiang_input}
#		2.	�ھ����ݸ�ʽ���Ľ�� 	${mining_input}
#		3.	ͼƬ���ݵı���·��		${path_data}
#	���:
#		1.	���տ����ṩ��ͼȤ���ߵ�����	${out}
#
###################################################################################
#	��������Ŀ¼
# 	filename 		��������ִ�еĽű��ļ���
# 	temp			�����м����ɵ���ʱ�ļ�Ŀ¼
#	input			�������ԭʼ����Ŀ¼���ֹ��ṩ������
#	swap			���ű����������ű�������/����ļ�Ŀ¼�����ű�֮�䴫���������
#	output			�����������ļ�
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
###################################################################################


###################################################################################
# ��������ļ�
# �ھ�ͺ����������� 
# normalize_mining_data.sh �����
mining_input=${swap}"/mining_data_normalized";
# normalize_dingxiang_data.sh �����
dingxiang_input=${swap}"/dingxiang_data_normalized";
# ͼƬ��������
path_data=${input}"/objs_local_path";
# ���ű������
out=${swap}"/final_objs_data";

###################################################################################
# ��ʱ�ļ�
# �������tagƵ��
tag_freq=${temp}".tag_freq";
# �ھ�����tag����
mining_data_tag_type=${temp}".mining_data.tag_type";
# ��������tag����
dingxiang_data_tag_type=${temp}".dingxiang_data.tag_type";
# ��������tag����
data_tag_type=${temp}".all_data.tag_type";
# tuhigh ��404������ͼƬ
error_404=${temp}".error_404"

###################################################################################
# �����ļ�
# �ھ�ͺ����ֱ����õİ�������ѡ��һ��obj��������һ��tag�ڰ�������
mining_white_tag="conf/mining_tag_list";
dingxiang_white_tag="conf/dingxiang_tag_list";

# �޸ı�ǩΪ������ǩ �� map
mining_modified_tag="conf/mining_tag_modified";
dingxiang_modified_tag="conf/dingxiang_tag_modified";

# ������������
type_index="conf/type_index";

# obj�ĺ�������tag����������
black_objs="./conf/obj_black_list";
black_tags="./conf/tag_black_list";

###################################################################################
# ���뿪ʼ

echo "��ʼ��һ����ʽ������..."

### 1. ��ϴ tag��ȥ��û��tag ��obj����tag�еĿո��滻Ϊ_����,�ָ�tag,ȥ���ظ���tag,ȥ����tag
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
    # ͼȤҪ��tag�в����пո���tag����,�ָ�
    delete tag_set;
    tag_str="";
    for(i in tags){
        tag=tags[i];
        if(tag=="")
            continue;
        gsub(" ","_",tag);
        gsub(",","_",tag);
        ## ͳһΪСд��ĸ
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
echo "��ϴtag...";
clean_tag ${mining_input} ${temp}.mining_clean_tag;
if [ ${?} -ne 0 ]
then
    echo "��ϴtagʧ�ܣ�";
    exit 1;
fi;
clean_tag ${dingxiang_input} ${temp}.dingxiang_clean_tag;
if [ ${?} -ne 0 ]
then
    echo "��ϴtagʧ�ܣ�";
    exit 1;
fi;

### 2. �������tag��freq
echo "����tagƵ��...";
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
    echo "����tagƵ��ʧ��!";
    exit 1;
fi;

### 3. ȷ��pm�Ĵ����
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
##print "�ֹ���"tag_freq["�ֹ�"];
            split($3,tags,",");
            delete types;
            for(i in tags){
                tag=tags[i];
                if(tag!="" && (tag in tag_type)){ # tag�����ڰ�������
                    a_type=tag_type[tag];
                    if(a_type!="" &&  tag_freq[types[a_type]]<tag_freq[tag]){  ## ͬһ�����µ����Ƶ��
                         ##print tag"*"a_type"*"tag_freq[types[a_type]]"*"tag_freq[tag];
                         types[a_type]=tag;
                    }
                }
            }
            conflict_mark=0;
            top_freq_tag=""; # ���Ƶ�ʵ�tag
            for(type in types){
                if(top_freq_tag=="")
                    top_freq_tag=types[type];
                else{
                    #ѡtagƵ����ߵ�������Ϊ��obj������
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
            if(conflict_mark==1){ #ǰ��������10W����ͻ��,�б�Ҫ�ھ����
                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag] > conflict_output
            }
        }
    }' ${func_tag_type_conf} ${tag_freq}  ${func_input} > ${func_output}
}
echo "ȷ��PM�����...";
determine_tag_type ${temp}.dingxiang_clean_tag ${dingxiang_white_tag} ${dingxiang_data_tag_type} ${temp}.dingxiang_type_conflict;
if [ ${?} -ne 0 ]
then
    echo "ȷ��obj�����Ĵ����ʧ�ܣ�";
    exit 1;
fi;
determine_tag_type ${temp}.mining_clean_tag ${mining_white_tag} ${mining_data_tag_type} ${temp}.mining_type_conflict;

if [ ${?} -ne 0 ]
then
    echo "ȷ��obj�����Ĵ����ʧ�ܣ�";
    exit 1;
fi;

## 4.1 �޸�һЩtagΪ�����tag������PM������: conf/*_tag_modified)
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


### 5 ȥ���������е�obj��ȥ���������е�tag������tag��Ϊ5. ���: ��ߴ�Ƶ��3�� + ����2/1��

echo "����tag������������tag��Ϊ5��...";
cat ${temp}.dingxiang_tag_modified ${temp}.mining_tag_modified > ${data_tag_type};
if [ ${?} -ne 0 ]
then 
    echo "�ϲ�����������ݺ��ھ�����ʧ�ܣ�";
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
            # ȡ3�����Ƶ��tag
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
        ## �� ʱ�д������ ���  ʱ�д��� �� ����
		if ($5==0) {
		}
		if($5==4){
            final_tags["ʱ�д���"];
            final_tags["����"];
        }else if($5==2){   ## �� �羰/���� ��� �羰 �� ����
            final_tags["�羰"];
            final_tags["����"];
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
    echo "���˺�����tagʧ�ܣ�";
    exit 1;
fi;

echo "�����ɢobj...";
###  �����ɢobj
awk -F '\t' '{
    print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"rand();
}' ${data_tag_type}.filter_tags >${temp}.all_data.tag_type_rand;
if [ ${?} -ne 0 ]
then
    echo "���������ʧ�ܣ�";
    exit 1;
fi;
sort -t'	' -r -n -k6,6 ${temp}.all_data.tag_type_rand |cut -f1,2,3,4,5 > ${out}.without_path;
if [ ${?} -ne 0 ]
then
    echo "�����������[��ɢobj]ʧ��!";
    exit 1;
fi;

echo "�ϲ�ͼƬ·������...";
### �ѱ���·���� path �ϲ���ȥ
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
    echo "�ϲ�ͼƬ·������ʧ�ܣ�";
    exit 1;
fi;

echo -e "��һ����ʽ���������. ����ļ�Ϊ ${out}"
