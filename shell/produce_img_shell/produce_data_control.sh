#!/bin/bash

###################################################################################
#
#	脚本功能: 
#		生成可用数据源主控制脚本 产生今天的图片索引以便图趣灌库
#
###################################################################################

log_file="./log/produce_img.log"
if [ ! -d "log" ]; then 
	mkdir log
fi

./shell/produce_img_shell/select_data.sh >> ${log_file} 2>&1
if [ $? -ne 0 ]; then
	echo "选择图片数据的主控制程序失败!" >> ${log_file}
	echo "图趣线上生成数据失败，请跟进检查." | mail -s "图趣线上数据报警" zhengwei04@baidu.com
	exit 1
fi
