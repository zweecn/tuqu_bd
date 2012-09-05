#/bin/bash

old_dir="data/img09/objInfoByTag.20120901.0"
new_dir="data/img09/objInfoByTag.20120901.1"

merge_dir="data/img09/objInfoByTag.merge"

log="log/merge_pinggu.log."`date +%Y%m%d`

mkdir -p $merge_dir

for name in `ls $new_dir` 
do
	new_path="${new_dir}/$name"
	old_path="${old_dir}/$name"
	merge_path="${merge_dir}/$name"

	err_flag=1
	ls $new_path
	if [ $? -ne 0 ]; then
		echo $new_path " not exist." >> $log
		err_flag=0
	fi
	ls $old_path
	if [ $? -ne 0 ]; then
		echo $old_path " not exist." >> $log
		err_flag=0
	fi
	
	if [ $err_flag -ne 1 ]; then
		continue
	fi

	awk -F '\t' '{
		if (FILENAME == ARGV[1]) {
			new[$1] = $0;
		} else {
			old[$1] = $0;	
		}
	} END {
		for (i in new) {
			split(new[i], new_arr, "\t");
			split(old[i], old_arr, "\t");
			res_new = new_arr[4];
			res_old = old_arr[4];

			if (res_new == 0) {
				print new[i];
			} else if (res_old == 0) {
				print old[i];	
			} else if (res_new == 1 && res_old == 1) {
				print new[i];	
			}
		}
	}' $new_path $old_path > $merge_path
done

