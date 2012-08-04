#!/bin/bash 

function format_data
{
	if [ $# -ne 1 ];then
		echo "²ÎÊı¸öÊı´íÎó£¬ÕıÈ·µÄ²ÎÊı¸öÊıÊÇ1."
		exit 1
	fi
	prefix=$1
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

	filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
	temp="./data/temp/"${filename}.${prefix}
	input="./data/input"
	swap="./data/swap/"${prefix}
	output="./data/output"
	today=`date +%Y%m%d`
###################################################################################

#############################################################################
# Êı¾İÎÄ¼ş
# Í¼Æ¬Â·¾¶Êı¾İ
	path_data=${input}"/objs_local_path"

# ¶¨ÏòÊı¾İÊäÈë
	in=${swap}"_data_normalized"

# ±¾½Å±¾µÄÊä³öÎÄ¼ş
	out=${swap}"_final_objs_data"

#############################################################################
# ÁÙÊ±ÎÄ¼ş
# ¼ÆËã³öµÄtagÆµ¶È
	tag_freq=${temp}".tag_freq"
	data_tag_type=${temp}".tag_type"

# »¹ĞèÒªÏÂÔØµÄÍ¼Æ¬£¬Òà¼´±¾µØÃ»ÓĞµÄÍ¼Æ¬
	urls_to_download=${temp}".urls_to_download"

#############################################################################
# ÅäÖÃÎÄ¼ş
# °×Ãûµ¥£¨Ñ¡ÔñÒ»¸öobjÖĞĞèÖÁÉÙÒ»¸ötagÔÚ°×Ãûµ¥£©
	white_tag="conf/"${prefix}"_tag_list"

# ºÚÃûµ¥(tagºÚÃûµ¥ºÍobjºÚÃûµ¥)
	black_objs="./conf/obj_black_list"
	black_tags="./conf/tag_black_list"

# ĞŞ¸Ä±êÇ©ÎªÆäËü±êÇ© ¼´ map
	modified_tag="conf/"${prefix}"_tag_modified"
	
# ÀàĞÍË÷Òı
	type_index="conf/type_index"

#############################################################################
# ´úÂë¿ªÊ¼
#

	echo -e "¿ªÊ¼¸ñÊ½»¯Êı¾İ ${prefix} ..."
	echo "source format_func.sh ..."
	source ./shell/produce_img_shell/format_func.sh
	if [ ${?} -ne 0 ]
	then
		echo "source failed."
		exit 1
	fi

### 1. ÇåÏ´ tag£¬È¥µôÃ»ÓĞtag µÄobj£¬°ÑtagÖĞµÄ¿Õ¸ñÌæ»»Îª_£¬ÓÃ,·Ö¸îtag,È¥µôÖØ¸´µÄtag,È¥µô¿Õtag
	echo "1. ÇåÏ´tag...";
	clean_tag ${in} ${temp}.clean_tag ${temp}.no_tag;
	if [ ${?} -ne 0 ]
	then
		echo "ÇåÏ´tagÊ§°Ü£¡";
		exit 1;
	fi;

### 2. ¼ÆËã¸÷¸ötagµÄfreq
	echo "2. ¼ÆËãtagÆµÂÊ...";
	cal_tag_freq ${temp}.clean_tag ${tag_freq}
	if [ ${?} -ne 0 ]
	then
		echo "¼ÆËãtagÆµÂÊÊ§°Ü!";
		exit 1;
	fi;

### 3. È·¶¨pmµÄ´ó·ÖÀà
	echo "3. È·¶¨PM´ó·ÖÀà...";
	determine_tag_type ${temp}.clean_tag ${white_tag} ${data_tag_type} ${temp}.type_conflict ${temp}.no_type
	if [ ${?} -ne 0 ]
	then
		echo "È·¶¨objËùÊôµÄ´ó·ÖÀàÊ§°Ü£¡";
		exit 1;
	fi;

### 4 ĞŞ¸ÄÒ»Ğ©tagÎªÁíÍâµÄtag£¨¸ù¾İPMµÄÅäÖÃ: conf/*_tag_modified)
	echo "4. ĞŞ¸Ätag..."
#	tag_modify ${tag_freq} ${modified_tag} ${data_tag_type} ${temp}.tag_modified ${tag_freq}.tag_modified
	tag_modify ${tag_freq} ${modified_tag} ${data_tag_type} ${data_tag_type}.tag_modified ${tag_freq}.tag_modified
	if [ ${?} -ne 0 ]
	then
		echo "ĞŞ¸ÄtagÊ§°Ü!";
		exit 1;
	fi;

### 5 È¥µôºÚÃûµ¥ÖĞµÄobj£¬È¥µôºÚÃûµ¥ÖĞµÄtag£¬ÏŞÖÆtagÊıÎª5. ×é³É: ×î¸ß´ÊÆµµÄ3¸ö + ÀàĞÍ2/1¸ö
	echo "5. ¹ıÂËtagºÚÃûµ¥£¬ÏŞÖÆtagÊıÎª5¸ö...";
#	remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type} ${data_tag_type}.filter_tags;
	remove_black_tag ${black_objs} ${black_tags} ${type_index} ${tag_freq}.tag_modified ${data_tag_type}.tag_modified ${data_tag_type}.filter_tags;
	if [ ${?} -ne 0 ]
	then
		echo "¹ıÂËºÚÃûµ¥tagÊ§°Ü£¡";
		exit 1;
	fi;

### **.dingxiang ÔÚ·ÖÀàĞÅÏ¢ºóÔö¼ÓÃ¿¸öÕ¾µãĞÅÏ¢, ¸üĞÂÃ¿¸öÀà±ğĞèÒªµÄÍ¼Æ¬ÊıÁ¿µÄÅäÖÃÎÄ¼
	if [ ${prefix} = "dingxiang" ]; then
		update_type_and_demand ${data_tag_type}.filter_tags ${temp}.filter_tags_tmp
	fi


### 6  Ëæ»ú´òÉ¢obj
	echo "6. Ëæ»ú´òÉ¢obj...";
	rand_obj ${data_tag_type}.filter_tags ${temp} ${out}.without_path
	if [ ${?} -ne 0 ]
	then
		echo "Ëæ»ú´òÉ¢objÊ§°Ü!";
		exit 1;
	fi;

### 7 °Ñ±¾µØÂ·¾¶ºÏ path ºÏ²¢½øÈ¥
	echo "7. ºÏ²¢Í¼Æ¬Â·¾¶Êı¾İ...";
	merge_path ${path_data} ${out}.without_path  ${out}  ${urls_to_download}
	if [ ${?} -ne 0 ]
	then
		echo "ºÏ²¢Í¼Æ¬Â·¾¶Êı¾İÊ§°Ü£¡";
		exit 1;
	fi;

	echo -e "¸ñÊ½»¯${suffix}Êı¾İÍê³É£¬Êä³öÊı¾İÎª ${out}"
}
