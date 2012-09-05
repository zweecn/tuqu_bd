#/bin/bash

dir_arr=("data/img09/objInfoByTag.20120827.withoutpath"
"data/img09/objInfoByTag.20120830")
#dir_arr=("data/img09/objInfoByTag.20120831"
#"data/img09/objInfoByTag.20120901"
#"data/img09/objInfoByTag.20120901.0"
#"data/img09/objInfoByTag.20120902")

#dir_arr=("data/img09/objInfoByTag.20120827.withoutpath"
#"data/img09/objInfoByTag.20120830"
#"data/img09/objInfoByTag.20120831"
#"data/img09/objInfoByTag.20120901"
#"data/img09/objInfoByTag.20120901.0"
#"data/img09/objInfoByTag.20120902")


merge_dir="data/img09/objInfoByTag.merge"
pm_tags="conf/pinggu_res_tags"

log="log/merge_pinggu.log."`date +%Y%m%d`

echo "Begin cal zero result..."
zero="data/img09/zero_obj"
zero_tmp="data/img09/zero_obj.tmp"
rm -rf $zero
rm -rf $zero_tmp
for d in ${dir_arr[@]} 
do
	echo $d
	while read tag
	do
		path="$d/${tag}.txt"
		awk -F '\t' '{
			if ($4 == 0) {
				print;
			}
		}' $path >> $zero_tmp 
	done < $pm_tags
done

rm -rf $zero
echo "Uniq zero..."
awk -F '\t' '{
	if (!mark[$1]) {
		mark[$1] = 1;
		print; 
	}
}' $zero_tmp > $zero

echo "Begin get result..."
rm -rf $merge_dir
mkdir -p $merge_dir
while read tag
do
	path="data/img09/objInfoByTag.20120902/${tag}.txt"
	new="${merge_dir}/${tag}.txt"
	echo $new
	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			z[$1] = 1;
		} else {
			if (!($1 in z)) {
				print;
			}
		}
	}' $zero $path > $new
done < $pm_tags


#echo "Find bad case..."
#tag="ÐÔ¸Ð.txt"
#local_jpg="data/res/46/12947849033380167/18.jpeg"
#
#
#objs_map="data/img09/objs_map"
#bad="data/img09/bad"
#rm -rf $bad
#obj=`awk -F '\t' -v jpg="${local_jpg}" '{
#	if ($3 == jpg)	
#		print $2;
#}' $objs_map `
#
#for d in ${dir_arr[@]} 
#do
#	path="$d/$tag"
#	echo $path
#	fgrep $obj $path | awk -F '\t' '{print $4;}'
#done

echo "Finished."
