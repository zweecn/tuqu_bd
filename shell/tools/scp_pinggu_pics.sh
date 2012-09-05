#!/bin/bash

tag_dir="data/img09/objInfoByTag.merge.0901"
tag_uniq_dir="data/img09/objInfoByTag.uniq"
uniq_md5="data/img09/uniq_md5_map"

death_link="data/img09/death_link"
all_tmp="data/img09/all_tmp"
all="data/img09/all"

mkdir $tag_uniq_dir

rm $all_tmp
while read tag
do
	tag_path="${tag_dir}/${tag}.txt"
	tag_uniq_path="${tag_uniq_dir}/${tag}.txt"
	awk -F '\t' '{
		if ($4 == 1) {
			print;	
		}
	}' $tag_path > ${tag_uniq_path}

	cat $tag_uniq_path >> $all_tmp 

done < conf/pinggu_res_tags


sort -k1 $all_tmp | uniq > $all

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		site[$1] = 1;
	} else {
		for (s in site) {
			if (index($0, s)) {
				print;
			}
		}
	}
}' conf/death_site data/img09/all > $death_link


objs_local="data/input/objs_local_path"
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		local_path[$2] = $1;
	} else {
		if (local_path[$1] != "") {
			print local_path[$1];
		}
	}
}' $objs_local $all > data/tmp/all_local_pics 

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		local_path[$2] = $1;
	} else {
		if (local_path[$1] != "") {
			print local_path[$1];
		}
	}
}' $objs_local $death_link > data/tmp/death_local_pics 

rm -rf data/img09/name_map
while read line
do
	echo $line
	dir="data/"`echo $line | awk -F '\t' '{
		split($1, arr, "client");
		print arr[2];
	}' | awk -F '/' '{
		print $2 "/" $3 "/" $4;
	}'`
	old_name="data"`echo $line | awk -F '\t' '{
		split($1, arr, "client");
		print arr[2];
	}'`
	
	mkdir -p $dir
	remote="img@jx-apptest-img04.vm.baidu.com:${line}"
	scp $remote $dir

	new_name=`echo $old_name | awk -F '.' '{print $1 ".";}'``file $old_name | cut -d' ' -f2 | awk '{print tolower($0);}'`
	mv $old_name $new_name
	echo $old_name $new_name >> data/img09/name_map	
done < data/tmp/death_local_pics

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		split($5, tags, "\\$\\$");
		for ( i in tags) {
			tag = tags[i];
			tag_cnt[tag]++;
		}
	} else {
		print $1 "\t" tag_cnt[$1];	
	}
}' $all conf/pinggu_res_tags > data/img09/all.txt

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		split($5, tags, "\\$\\$");
		for ( i in tags) {
			tag = tags[i];
			tag_cnt[tag]++;
		}
	} else {
		print $1 "\t" tag_cnt[$1];	
	}
}' $death_link conf/pinggu_res_tags > data/img09/death_link.txt

good="data/img09/good"
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		death[$1] = 1;
	} else {
		if ($1 in death)
			next;
		print;
	}
}' $death_link $all > $good
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		split($5, tags, "\\$\\$");
		for ( i in tags) {
			tag = tags[i];
			tag_cnt[tag]++;
		}
	} else {
		print $1 "\t" tag_cnt[$1];	
	}
}' $good conf/pinggu_res_tags > data/img09/good.txt


echo "Finished."
