#!/bin/bash

prefix="dingxiang"

filename="pre_online"
temp="./data/temp/"${filename}.${prefix}
input="./data/input"
swap="./data/swap/"${prefix}
output="./data/output"
today=`date +%Y%m%d`

white_tag="conf/"${prefix}"_tag_list"
data_tag_type=${temp}".tag_type"

tag_freq=${temp}".tag_freq"

function determine_tag_type
{
	echo -e "	ȷ��PM�����������ļ��� $1 `wc -l $1 | cut -d ' ' -f 1` ��"
   	local func_input=$1;
   	local func_tag_type_conf=$2;
    local func_output=$3;
    local func_conflict_output=$4;
	local no_type_out=$5;
	local pm_stat_tags=$6;
	local stat_tag=$7; 
	awk -F '\t' -v stat_tag_out="${stat_tag}" -v conflict_output="${func_conflict_output}" -v no_out="${no_type_out}" '{
        if (FILENAME == ARGV[1]) {
			pm_tag_cnt[$1] = $2;	
			total_tag_cnt[$1] = 0;
			conflict_tag_cnt[$1] = 0;
			no_tag_cnt[$1] = 0;
			tag_left_cnt[$1] = 0;
		}else if(FILENAME==ARGV[2]){
            tag_type[$1]=$2;
        }else if(FILENAME==ARGV[3]){
            tag_freq[$1]=$2;
        }else{
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
			
			if(conflict_mark==1){ #ǰ��������10W����ͻ��,�б�Ҫ�ھ����
                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag] > conflict_output;
            } else if(top_freq_tag!=""){
                # objURL    fromURL tags    top_freq_tag    type
                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag];
            } else {
                print $0 > no_out;
			}

			for (i in tags) {
				tag = tags[i];
				if (!(tag in pm_tag_cnt)) {
					continue;
				}

				total_tag_cnt[tag]++;		
				if (conflict_mark) {
					conflict_tag_cnt[tag]++;
				} else if (top_freq_tag != "") {
					tag_left_cnt[tag]++;
				} else {
					no_tag_cnt[tag]++;
				}
			}
        }
    } END {
		print "tag \t PMͳ��ֵ \t ȥ����tag��ͳ��ֵ \t = ��ͻͳ��ֵ + �޷���ֵ + ��Чͳ��ֵ" > stat_tag_out;
		for (tag in pm_tag_cnt) {
			print tag "\t" pm_tag_cnt[tag] "\t" total_tag_cnt[tag] "\t" conflict_tag_cnt[tag] "\t" no_tag_cnt[tag] "\t" tag_left_cnt[tag] > stat_tag_out; 
		}
	}' ${pm_stat_tags} ${func_tag_type_conf} ${tag_freq}  ${func_input} > ${func_output}
	echo -e "	ȷ��PM����������ļ�Ϊ ${func_output} `wc -l ${func_output} | cut -d' ' -f 1` ��"
	echo -e	"	��ͻ�ļ�Ϊ ${func_conflict_output} `wc -l ${func_conflict_output} | cut -d' ' -f 1` ��"
	echo -e	"	û�������Ϊ ${no_type_out} `wc -l ${no_type_out} | cut -d' ' -f 1` ��"
	echo -e "	tag ͳ�ƽ�����Ϊ ${stat_tag}"
}

echo "Begin..."

determine_tag_type ${temp}.clean_tag ${white_tag} ${data_tag_type} ${temp}.type_conflict ${temp}.no_type "./conf/dingxiang_pm_tag_count" ${temp}.stat_tag

echo "END"
