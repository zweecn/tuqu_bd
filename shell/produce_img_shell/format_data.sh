#!/bin/bash 

function format_data
{
	if [ $# -ne 1 ];then
		echo "²ÎÊı¸öÊı´íÎó£¬ÕıÈ·µÄ²ÎÊı¸öÊıÊÇ1."
		exit 1
	fi
	local prefix=$1
	if [ $prefix != "dingxiang" -a $prefix != "mine" ]; then
		echo "²ÎÊı´íÎó. ÕıÈ·µÄ²ÎÊıÖ»ÄÜÊÇ1¸ö: dingxiang »òÕß mine ."
		exit 1
	fi

###################################################################################
#	»ù±¾Êı¾İÄ¿Â¼
# 	filename 		³ÌĞòÕıÔÚÖ´ĞĞµÄ½Å±¾ÎÄ¼şÃû
# 	temp			³ÌĞòÖĞ¼äÉú³ÉµÄÁÙÊ±ÎÄ¼şÄ¿Â¼
#	input			Ö÷³ÌĞòµÄÔ­Ê¼ÊäÈëÄ¿Â¼£¬ÊÖ¹¤Ìá¹©µÄÊı¾İ
#	swap			±¾½Å±¾»òÕßÆäËû½Å±¾µÄÊäÈë/Êä³öÎÄ¼şÄ¿Â¼£¬¹©½Å±¾Ö®¼ä´«µİÊäÈëÊä³ö
#	output			Ö÷³ÌĞòµÄÊä³öÎÄ¼ş
#	today			½ñÌìµÄÈÕÆÚ£¬¸ñÊ½ÊÇÀàËÆÓÚ "20120802"

	local filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
	local temp="./data/temp/"${filename}.${prefix}
	local input="./data/input"
	local swap="./data/swap/"${prefix}
	local output="./data/output"
	local today=`date +%Y%m%d`
###################################################################################

#############################################################################
# Êı¾İÎÄ¼ş
# Í¼Æ¬Â·¾¶Êı¾İ
	local path_data=${input}"/objs_local_path"

# ¶¨ÏòÊı¾İÊäÈë
	local in=${swap}"_data_normalized"

# ±¾½Å±¾µÄÊä³öÎÄ¼ş
	local out=${swap}"_final_objs_data"
	local out_without_path=${out}.without_path

# ±¾½Å±¾Í³¼ÆµÄtagÇé¿öÊä³öÎÄ¼ş 
	local out_tag_stat=${swap}"_tag_stat"
		
#############################################################################
# ÁÙÊ±ÎÄ¼ş
# ¼ÆËã³öµÄtagÆµ¶È
	local tag_freq=${temp}".tag_freq"
	local data_tag_type=${temp}".tag_type"

# »¹ĞèÒªÏÂÔØµÄÍ¼Æ¬£¬Òà¼´±¾µØÃ»ÓĞµÄÍ¼Æ¬
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
# ÅäÖÃÎÄ¼ş
# °×Ãûµ¥£¨Ñ¡ÔñÒ»¸öobjÖĞĞèÖÁÉÙÒ»¸ötagÔÚ°×Ãûµ¥£©
	local white_tag="./conf/"${prefix}"_tag_list"

# ºÚÃûµ¥(tagºÚÃûµ¥ºÍobjºÚÃûµ¥)
	local black_objs="./conf/obj_black_list"
	local black_tags="./conf/tag_black_list"

# ĞŞ¸Ä±êÇ©ÎªÆäËü±êÇ© ¼´ map
	local modified_tag="./conf/tag_modified"

	local clear_char="./conf/clear_char"
# ÀàĞÍË÷Òı
	local type_index="./conf/type_index"

# PM Í³¼ÆµÄtagÖµ
	local pm_tags="./conf/"${prefix}"_pm_tag_count"

#############################################################################
# ´úÂë¿ªÊ¼
#
	echo -e "[format_data.sh] ¿ªÊ¼¸ñÊ½»¯ ${prefix}..."
	echo "	source format_func.sh ..."
	source ./shell/produce_img_shell/format_func.sh
	if [ ${?} -ne 0 ]
	then
		echo "source failed."
		exit 1
	fi

### 1. ÇåÏ´ tag£¬È¥µôÃ»ÓĞtag µÄobj£¬°ÑtagÖĞµÄ¿Õ¸ñÌæ»»Îª_£¬ÓÃ,·Ö¸îtag,È¥µôÖØ¸´µÄtag,È¥µô¿Õtag
	echo "1. ÇåÏ´tag..."
	clean_tag ${in} ${tag_cleaned} ${no_tag}
	if [ ${?} -ne 0 ]
	then
		echo "ÇåÏ´tagÊ§°Ü£¡";
		exit 1;
	fi

### 2. ĞŞ¸ÄÒ»Ğ©tagÎªÁíÍâµÄtag£¨¸ù¾İPMµÄÅäÖÃ: conf/*_tag_modified)
	echo "2. ĞŞ¸Ätag..."
	pre_tag_modify ${modified_tag} ${clear_char} ${tag_cleaned} ${tag_modified}
	if [ ${?} -ne 0 ]
	then
		echo "ĞŞ¸ÄtagÊ§°Ü£¡";
		exit 1;
	fi;

### 3. ¼ÆËã¸÷¸ötagµÄfreq
	echo "3. ¼ÆËãtagÆµÂÊ...";
	cal_tag_freq ${tag_modified} ${tag_freq}
	if [ ${?} -ne 0 ]
	then
		echo "¼ÆËãtagÆµÂÊÊ§°Ü!";
		exit 1;
	fi;

### 4. È·¶¨pmµÄ´ó·ÖÀà
	echo "4. È·¶¨PM´ó·ÖÀà...";
	determine_tag_type ${tag_modified} ${white_tag} ${data_tag_type} ${type_conflict} ${no_type} ${pm_tags} ${stat_tag_res}
	if [ ${?} -ne 0 ]
	then
		echo "È·¶¨objËùÊôµÄ´ó·ÖÀàÊ§°Ü£¡";
		exit 1;
	fi;

### 5 È¥µôºÚÃûµ¥ÖĞµÄobj£¬È¥µôºÚÃûµ¥ÖĞµÄtag£¬ÏŞÖÆtagÊıÎª5. ×é³É: ×î¸ß´ÊÆµµÄ3¸ö + ÀàĞÍ2/1¸ö
	echo "5. ¹ıÂËtagºÚÃûµ¥£¬ÏŞÖÆtagÊıÎª5¸ö...";
	remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq} ${data_tag_type} ${filter_tags} ${white_tag}
	if [ ${?} -ne 0 ]
	then
		echo "¹ıÂËºÚÃûµ¥tagÊ§°Ü£¡";
		exit 1;
	fi;

### **.dingxiang ÔÚ·ÖÀàĞÅÏ¢ºóÔö¼ÓÃ¿¸öÕ¾µãĞÅÏ¢, ¸üĞÂÃ¿¸öÀà±ğĞèÒªµÄÍ¼Æ¬ÊıÁ¿µÄÅäÖ
	if [ ${prefix} = "dingxiang" ]; then
		update_type_and_demand ${filter_tags} 
	fi


### 6  Ëæ»ú´òÉ¢obj
	echo "6. Ëæ»ú´òÉ¢obj...";
	rand_obj ${filter_tags} ${temp} ${out_without_path}
	if [ ${?} -ne 0 ]
	then
		echo "Ëæ»ú´òÉ¢objÊ§°Ü!";
		exit 1;
	fi;

### 7 °Ñ±¾µØÂ·¾¶ºÏ path ºÏ²¢½øÈ¥
	echo "7. ºÏ²¢Í¼Æ¬Â·¾¶Êı¾İ...";
	merge_path ${path_data} ${out_without_path}  ${out}  ${urls_to_download} ${black_objs}
	if [ ${?} -ne 0 ]
	then
		echo "ºÏ²¢Í¼Æ¬Â·¾¶Êı¾İÊ§°Ü£¡";
		exit 1;
	fi;
	
### 8 Í³¼Ætag¸öÊıÇé¿ö
	echo "8. Í³¼Ætag¸öÊıÇé¿ö..."
	stat_tags_final_objs ${modified_tag} ${pm_tags} ${out_without_path} ${out}  ${final_tag_stat}
	if [ ${?} -ne 0 ]
	then
		echo "Í³¼Ætag¸öÊıÊ§°Ü!";
		exit 1;
	fi;

### 9 ºÏ²¢tag¸öÊıÇé¿ö	
	echo "9. ºÏ²¢tag¸öÊıÇé¿ö..."
	merge_tags_stat ${modified_tag} ${stat_tag_res} ${final_tag_stat} ${out_tag_stat}
	if [ ${?} -ne 0 ]
	then
		echo "ºÏ²¢tagÍ³¼ÆÇé¿öÊ§°Ü!";
		exit 1;
	fi;
	
	echo -e "[Êä³ö]	¸ñÊ½»¯${suffix}Êı¾İÍê³É£¬Êä³öÊı¾İÎª ${out}"
}

