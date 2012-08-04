#!/bin/bash

#############################################################################
# 
# formatÊı¾İµÄº¯Êı½Å±¾
# ÊÊÓÃÓÚÍÚ¾òÊı¾İºÍ¶¨ÏòÊı¾İµÄ¸ñÊ½»¯
# µ÷ÓÃÇ°ÏÈÖ´ĞĞ source ./shell/produce_img/format_func.sh
#
#############################################################################

### 1. ÇåÏ´ tag£¬È¥µôÃ»ÓĞtag µÄobj£¬°ÑtagÖĞµÄ¿Õ¸ñÌæ»»Îª_£¬ÓÃ,·Ö¸îtag,È¥µôÖØ¸´µÄtag,È¥µô¿Õtag
function clean_tag
{
    local func_input=$1
    local func_output=$2
	local no_tag=$3
	echo -e "	ÇåÏ´tagÇ°£¬ÊäÈëÎÄ¼şÎª ${func_input} `wc -l ${func_input} | cut -d ' ' -f 1` ĞĞ"
    awk -F '\t' -v out="${no_tag}" '{
		# objURL    fromURL     tags
		if($1=="" || $2=="" || $3==""){
			print $0 > out;
			next;
		}
		split($3,tags,"\\$\\$");
		# Í¼È¤ÒªÇótagÖĞ²»ÄÜÓĞ¿Õ¸ñ£¡ÇÒtagĞèÓÃ,·Ö¸î
		delete tag_set;
		tag_str="";
		for(i in tags){
			tag=tags[i];
			if(tag=="")
				continue;
			gsub(" ","_",tag);
			gsub(",","_",tag);
			## Í³Ò»ÎªĞ¡Ğ´×ÖÄ¸
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
	echo -e "	ÇåÏ´tagºó£¬Êä³öÎÄ¼şÎª ${func_output} `wc -l ${func_output} | cut -d ' ' -f 1` ĞĞ"
	echo -e "	Ã»ÓĞtagµÄÍ¼Æ¬£¬Êä³öÎª ${no_tag} `wc -l ${no_tag} | cut -d ' ' -f 1` ĞĞ"
}

### 2. ¼ÆËãtagÆµÂÊ
function cal_tag_freq
{
	local data_clean_tag=$1
	local tag_freq=$2
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
	}' ${data_clean_tag} > ${tag_freq}
	echo -e "	¼ÆËãtagÆµÂÊÊä³öÎª ${tag_freq}"
}

### 3. È·¶¨pmµÄ´ó·ÖÀà
function determine_tag_type
{
	echo -e "	È·¶¨PM´ó·ÖÀàµÄÊäÈëÎÄ¼şÊÇ $1 `wc -l $1 | cut -d ' ' -f 1` ĞĞ"
   	local func_input=$1;
   	local func_tag_type_conf=$2;
    local func_output=$3;
    local func_conflict_output=$4;
	local no_type_out=$5;
    awk -F '\t' -v conflict_output="${func_conflict_output}" -v no_out="${no_type_out}" '{
        if(FILENAME==ARGV[1]){
            tag_type[$1]=$2;
        }else if(FILENAME==ARGV[2]){
            tag_freq[$1]=$2;
        }else{
            split($3,tags,",");
            delete types;
            for(i in tags){
                tag=tags[i];
                if(tag!="" && (tag in tag_type)){ # tag±ØĞëÔÚ°×Ãûµ¥ÖĞ
                    a_type=tag_type[tag];
                    if(a_type!="" &&  tag_freq[types[a_type]]<tag_freq[tag]){  ## Í¬Ò»ÀàĞÍÏÂµÄ×î¸ßÆµÂÊ
                         ##print tag"*"a_type"*"tag_freq[types[a_type]]"*"tag_freq[tag];
                         types[a_type]=tag;
                    }
                }
            }
            conflict_mark=0;
            top_freq_tag=""; # ×î¸ßÆµÂÊµÄtag
            for(type in types){
                if(top_freq_tag=="")
                    top_freq_tag=types[type];
                else{
                    #Ñ¡tagÆµÂÊ×î¸ßµÄÀàĞÍ×÷Îª¸ÃobjµÄÀàĞÍ
                    tag=types[type];
                    if(tag_freq[tag]>tag_freq[top_freq_tag])
                        top_freq_tag=tag;
                    conflict_mark=1;
                }
            }
            ##print $3"*"top_freq_tag"*"tag_type[top_freq_tag];
			
			if(conflict_mark==1){ #Ç°ºóÊı¾İÓĞ10WÌõ³åÍ»µÄ,ÓĞ±ØÒªÍÚ¾ò³öÀ´
                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag] > conflict_output;
            } else if(top_freq_tag!=""){
                # objURL    fromURL tags    top_freq_tag    type
                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag];
            } else {
                print $0 > no_out;
			}
#            if(top_freq_tag!=""){
#                # objURL    fromURL tags    top_freq_tag    type
#                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag];
#            } 
#			 if(conflict_mark==1){ #Ç°ºóÊı¾İÓĞ10WÌõ³åÍ»µÄ,ÓĞ±ØÒªÍÚ¾ò³öÀ´
#                print $1"\t"$2"\t"$3"\t"top_freq_tag"\t"tag_type[top_freq_tag] > conflict_output;
#			 }

        }
    }' ${func_tag_type_conf} ${tag_freq}  ${func_input} > ${func_output}
	echo -e "	È·¶¨PM´ó·ÖÀàºó£¬Êä³öÎÄ¼şÎª ${func_output} `wc -l ${func_output} | cut -d' ' -f 1` ĞĞ"
	echo -e	"	³åÍ»ÎÄ¼şÎª ${func_conflict_output} `wc -l ${func_conflict_output} | cut -d' ' -f 1` ĞĞ"
	echo -e	"	Ã»±»·ÖÀàµÄÎª ${no_type_out} `wc -l ${no_type_out} | cut -d' ' -f 1` ĞĞ"
}


### 4 ĞŞ¸ÄÒ»Ğ©tagÎªÁíÍâµÄtag£¨¸ù¾İPMµÄÅäÖÃ: conf/*_tag_modified)
function tag_modify
{
	local tag_freq=$1
	local suffix_modified_tag=$2
	local suffix_data_tag_type=$3
	local tag_modify_out=$4
	local tag_freq_modified=$5
	awk -F '\t' -v out="${tag_modify_out}" '{
		if(FILENAME==ARGV[1]){
			tag_freq[$1]=$2;
		}else if(FILENAME==ARGV[2]){
			suffix_tag_change[$1]=$2;
			if(!($2 in tag_freq))
				tag_freq[$2]=tag_freq[$1];
		}else if(FILENAME==ARGV[3]){
			split($3,tags,",");
			tag_str="";
			for(i in tags){
				tag=tags[i];
				if(tag in suffix_tag_change){
					tag=suffix_tag_change[tag];
				}
				if(tag_str=="")
					tag_str=tag;
				else
					tag_str=tag_str","tag;
			}
			top_tag=($4 in suffix_tag_change)?suffix_tag_change[$4]:$4;
			print $1"\t"$2"\t"tag_str"\t"top_tag"\t"$5 > out;
		}	
	} END {
		for(tag in tag_freq){
				print tag"\t"tag_freq[tag];
		}
	}' ${tag_freq} ${suffix_modified_tag} ${suffix_data_tag_type} > ${tag_freq_modified}
	echo -e "	ĞŞ¸ÄÒ»Ğ©tagÎªÁíÍâµÄtagºó£¬Êä³öÎÄ¼şÎª ${tag_modify_out} `wc -l ${tag_modify_out} | cut -d ' ' -f 1` ĞĞ"
}


### 5 È¥µôºÚÃûµ¥ÖĞµÄobj£¬È¥µôºÚÃûµ¥ÖĞµÄtag£¬ÏŞÖÆtagÊıÎª5. ×é³É: ×î¸ß´ÊÆµµÄ3¸ö + ÀàĞÍ2/1¸ö
function remove_black_tag 
{
	local black_objs=$1
	local black_tags=$2
	local type_index=$3
	local tag_freq_modified=$4
	local data_tag_type=$5
	local data_tag_type_filter_tags=$6
	
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
			tag4="";
			for(i in tags){
				tag=tags[i];
				# È¡4¸ö×î¸ßÆµµÄtag
				if(tag!=top_freq_tag && tag!=type && !(tag in tag_black)){
					if(tag1=="" || tag_freq[tag]>tag_freq[tag1]){
						tag1=tag;
					}else if(tag2=="" || tag_freq[tag]>tag_freq[tag2]){
						tag2=tag;
					}else if(tag3=="" || tag_freq[tag]>tag_freq[tag3]){
						tag3=tag;
					}else if(tag4=="" || tag_freq[tag]>tag_freq[tag4]){
						tag4=tag;	
					}
				}
			}
			delete final_tags;
			if(!(top_freq_tag in tag_black)){
				final_tags[top_freq_tag];
			}

######################################################################			
## 			°Ñ Ê±ÉĞ´îÅä·şÊÎ ²ğ³É  Ê±ÉĞ´îÅä ºÍ ·şÊÎ
#			if($5==4){
#				final_tags["Ê±ÉĞ´îÅä"];
#				final_tags["·şÊÎ"];
#			}else if($5==2){   ## °Ñ ·ç¾°/ÂÃĞĞ ²ğ³É ·ç¾° ºÍ ÂÃĞĞ
#				final_tags["·ç¾°"];
#				final_tags["ÂÃĞĞ"];
#			}else if($5!=0){
#				final_tags[type_index[$5]];
#			}
######################################################################			
			
			if($5!=0){
				final_tags[type_index[$5]];
			}

			if(tag1!="")
				final_tags[tag1];
			if(tag2!="")
				final_tags[tag2];
			if(tag3!="")
				final_tags[tag3];
			if(tag4!="")
				final_tags[tag4];
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
	}' ${black_objs} ${black_tags} ${type_index} ${tag_freq_modified} ${data_tag_type} > ${data_tag_type_filter_tags};
	echo -e "	È¥µôºÚÃûµ¥ºóÊä³öÎÄ¼şÎª ${data_tag_type_filter_tags} `wc -l ${data_tag_type_filter_tags} | cut -d' ' -f 1` ĞĞ"
}

### **.dingxiang ÔÚ·ÖÀàĞÅÏ¢ºóÔö¼ÓÃ¿¸öÕ¾µãĞÅÏ¢, ¸üĞÂÃ¿¸öÀà±ğĞèÒªµÄÍ¼Æ¬ÊıÁ¿µÄÅäÖÃÎÄ¼
function update_type_and_demand
{
	local inout=$1
	local temp=$2
	echo "	** ¶¨ÏòÊı¾İĞèÒªÍ³¼ÆÀ´Ô´Êı¾İÕ¼±È..."
	perl -lne '{
		if ($_ =~ /\/\/(.*?)\/.+?\/\/(.*?)\//) { 
			@F = split(/\./, $2);
			$domain = $F[@F-2].".".$F[@F-1];
			print $domain."\t".$_;
		}
	}' ${inout} | awk -F '\t' '{
		domain_type = $1"-"$6;
		print $2 "\t" $3 "\t" $4 "\t" $5 "\t" domain_type;
	} END {
	}' > ${temp}

	mv ${inout} ${inout}.old
	echo -e "	±¸·İ${inout} Îª ${inout}.old"
	mv ${temp} ${inout}
	echo -e "	¸üĞÂÍ¼Æ¬Õ¾µãĞèÇóĞÅÏ¢Íê³É£¬Êä³öÎª ${inout} `wc -l ${inout} | cut -d' ' -f 1` ĞĞ"
}

### 6  Ëæ»ú´òÉ¢obj
function rand_obj
{
	local data_tag_type_filter_tags=$1
	local temp=$2
	local output_without_path=$3
	awk -F '\t' '{
    	print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"rand();
	}' ${data_tag_type_filter_tags} > ${temp}.all_data.tag_type_rand;
	if [ ${?} -ne 0 ]
	then
    	echo "Éú³ÉËæ»úÊıÊ§°Ü£¡";
    	exit 1;
	fi;
	sort -t'	' -r -n -k6,6 ${temp}.all_data.tag_type_rand |cut -f1,2,3,4,5 > ${output_without_path};
	if [ ${?} -ne 0 ]
	then
    	echo "¶ÔËæ»úÊıÅÅĞò[´òÉ¢obj]Ê§°Ü!";
    	exit 1;
	fi;

	echo -e "	´òÉ¢ºó£¬Êä³öÎÄ¼şÎª ${output_without_path} `wc -l ${output_without_path} | cut -d ' ' -f 1` ĞĞ"
}

### 7 merge the img local path
function merge_path
{
	local path_data=$1
	local output_without_path=$2
	local output=$3
	local urls_to_download=$4
	awk -F '\t' -v urls_to_download="${urls_to_download}" '{
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
	}' ${path_data} ${output_without_path} > ${output}

	echo -e "	ºÏ²¢±¾µØÂ·¾¶ºó£¬Êä³öÎÄ¼şÎª ${output} `wc -l ${output} | cut -d ' ' -f 1` ĞĞ"
}
