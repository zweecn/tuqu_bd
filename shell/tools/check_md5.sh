#!/bin/bash

echo "[TIME START]" `date "+%Y%m%d-%H:%M:%S"`

md5_map="data/img09/name_map_md5"
all_map="data/img09/all_map"

#cat data/img09/name_map data/img09/name_good_map | sort | uniq > $all_map
##cat data/img09/name_map | sort | uniq > $all_map
#
#echo "Begin cal the md5..."
#rm -rf $md5_map
#while read old_name new_name
#do
#	md5=`md5sum $new_name | cut -d' ' -f1`
#	echo $old_name $new_name $md5 >> $md5_map 
#done < $all_map 
#
#md5_cnt=`cut -d' ' -f3 $md5_map | sort | uniq | wc -l`
#md5_map_cnt=`sort $md5_map | uniq | wc -l`
#
#echo "md5_cnt="$md5_cnt "map_cnt="$md5_map_cnt
#
#echo "Begin uniq the pics..."
#uniq_md5="data/img09/uniq_md5_map"
#awk -F ' ' '{
#	pic[$3] = $2;
#	html[$3] = $1;	
#	if (!mark[$3]) {
#		mark[$3] = 1;
#		print;
#	}
#}' $md5_map > $uniq_md5 


echo "Begin cal the same md5 pics..."
same_md5="data/img09/same_md5"
awk -F ' ' '{
	print $3 "\t" $2;
}' $md5_map | sort | uniq > ${md5_map}.sort
awk -F ' ' '{
	if ($1 != md5) {
		if (cnt > 1)
			print pre_line;
		md5 = $1;
		cnt = 1;
	} else {
		cnt++;
		if (cnt > 1)
			print pre_line;
	}
	pre_line = $0;
}' ${md5_map}.sort > ${same_md5}

echo "Begin uniq the same pics..."
awk -F '\t' '{
	if (!mark[$2]) {
		print $2;
		mark[$2] = 1;
	}
}' $same_md5 > data/img09/same_pics

echo "Begin cp the same pics..."
pics="data/img09/pics"
rm -rf $pics
mkdir -p $pics
i=0
while read pic
do
	i=$(($i+1))
	ex=`echo $pic | cut -d'.' -f2`
	echo $pic
	cp $pic "${pics}/${i}.${ex}"
done < data/img09/same_pics

echo "Finished."
echo "[TIME END]" `date "+%Y%m%d-%H:%M:%S"`
