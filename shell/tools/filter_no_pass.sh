#/bin/bash

d="data/img09/objInfoByTag"
filter_dir="data/img09/objInfoByTag.filter"
pm_tags="conf/pinggu_res_tags"
log="log/merge_pinggu.log."`date +%Y%m%d`
zero="data/img09/zero_obj"
zero_tmp="data/img09/zero_obj.tmp"
zero_no_md5="data/img09/zero_obj.no_md5"
objs_map="data/img09/objs_map"

echo "Begin cal zero result..."
rm -rf $zero_tmp
while read tag
do
	path="$d/${tag}.txt"
	echo $path
	awk -F '\t' '{
		if ($4 == 0) {
			print;
		}
	}' $path >> $zero_tmp 
done < $pm_tags

rm -rf $zero
echo "Uniq zero..."
awk -F '\t' '{
	if (!mark[$1]) {
		mark[$1] = 1;
		print; 
	}
}' $zero_tmp > $zero_no_md5

awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		md5[$2] = $4;
	} else {
		print $0 "\t" md5[$1];
	}
}' $objs_map $zero_no_md5 > $zero 

echo "Begin get result..."
rm -rf $filter_dir
mkdir -p $filter_dir
while read tag
do
	path="${d}/${tag}.txt"
	new="${filter_dir}/${tag}.txt"
	echo $path "-->" $new
	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			z[$1] = 1;
			zero_md5[7] = 1;
		} else if (FILENAME == ARGV[2] ) { 
			md5[$2] = $4;
		} else {
			if ($1 in z)
				next;
			if (md5[$1] in zero_md5) {
				print md5[$1] >> "md5";
				next;
			}
			split($2, arr, "\\.");
			if (arr[2] == "jpeg" || arr[2] == "png" || arr[2] == "gif" || arr[2] == "jpg")
				print;
			else 
				print arr[2] >> "ex";
		}
	}' $zero $objs_map $path > $new
done < $pm_tags

echo "Finished."
