#!/bin/bash

#if [ "${x+X}" = X ]; then
#	echo "YES"
#fi
#
#echo ${RANDOM}{,,,}
#
#while IFS=: read login a b c name e
#do
#	printf "%-12s %s\n" "$login" "$name"
#done < /etc/passwd

#while read obj tags from_url path
#do
#	echo $tags
#done < data/swap/dingxiang_final_objs_data

#fun()
#{
#	echo "In func"
#	return 1
#}
#
#[ -f 1 ] && ( fun || echo "Failed")

#cmd=data/temp/sed_cmd
#
#awk -F '\t' '{
#	old_chars[$1] = 1;
#
#} END {
#	for (old in old_chars) {
#		print "s/" old "//g";
#	}
#}' conf/clear_char > ${cmd}
#
#sed -f ${cmd}  1 > 2 

n=0
b=$((${n:-0}))
echo $b
