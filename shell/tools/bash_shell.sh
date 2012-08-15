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

while read obj tags from_url path
do
	echo $tags
done < data/swap/dingxiang_final_objs_data
