#!/bin/bash

function restore_used_objs
{
	used_objs="data/input/used_objs"
	backup_dir="data/input/used_objs_backup"

	yesterday=`date -d"1 day ago" +"%Y%m%d"`
	two_days_ago=`date -d"2 day ago" +"%Y%m%d"`
	three_days_ago=`date -d"3 day ago" +"%Y%m%d"`

	all_used=`ls ${backup_dir}/*${yesterday}*`
	if [ $? -ne 0 ]; then
		echo "昨天的used_objs不存在，尝试前天的."
		all_used=`ls ${backup_dir}/*${two_days_ago}*`
		if [ $? -ne 0 ]; then
			all_used=`ls ${backup_dir}/*${three_days_ago}*`
			if [ $? -ne 0 ]; then
				echo "前天的used_objs不存在，尝试所有的."
				all_used=`ls ${backup_dir}`
				if [ $? -ne 0 ]; then
					echo "没有备份的used_objs，失败!"
					exit 1
				fi
			fi
		fi
	fi

	for used in ${all_used[@]}
	do
		echo ${used}
		awk -F '\t' '{
			if (!mark[$1]) {
				print;
				mark[$1] = 1;
			}
		}' ${used} >  ${used_objs}.tmp
	done

	if [ -s ${used_objs}.tmp ]; then
		mv ${used_objs}.tmp ${used_objs}
	fi
}

restore_used_objs
