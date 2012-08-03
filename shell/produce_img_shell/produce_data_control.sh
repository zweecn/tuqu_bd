#!/bin/bash

###################################################################################
#
#	脚本功能: 
#		生成可用数据源主控制脚本 产生今天的图片索引以便图趣灌库
#	分3步骤进行:
#		I.		 生成定向的数据
#		II.		 生成挖掘的数据
#		III.	 对生成的数据进行善后处理(替换HTML字符，传输到远程主机)
#
###################################################################################

echo "开始产生数据..."
date

echo "开始产生定向数据..."
###################################################################################
#
#	I.		 生成定向的数据
#
# 	1.	合作（定向）数据 第一步格式化
./shell/produce_img_shell/normalize_dingxiang_data.sh;
if [ ${?} -ne 0 ]
then 
    echo "定向数据格式化失败."
    exit 1;
fi

#	2.	进一步格式化定向数据，包括筛选和替换等等
echo "source format_data.sh ..."
source ./shell/produce_img_shell/format_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
format_data "dingxiang"
if [ $? -ne 0 ]
then
	echo "进一步格式化定向数据失败."
	exit 1
fi

# 	3. 选择定向数据
echo "source select_data.sh ..."
source ./shell/produce_img_shell/select_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
select_data "dingxiang"
if [ $? -ne 0 ]
then
	echo "选择定向数据失败."
	exit 1
fi

echo "产生定向数据完成."
date

echo "开始产生挖掘数据..."
###################################################################################
#
#	II.		 生成挖掘的数据
#
# 	1.	挖掘数据 第一步格式化
./shell/produce_img_shell/normalize_mining_data.sh
if [ ${?} -ne 0 ]
then 
    echo "挖掘数据格式化失败."
    exit 1;
fi

#	2.	进一步格式化挖掘数据，包括筛选和替换等等
echo "source format_data.sh ..."
source ./shell/produce_img_shell/format_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
format_data "mine"
if [ $? -ne 0 ]
then
	echo "进一步格式化定向数据失败."
	exit 1
fi

# 	3. 选择挖掘数据
echo "source select_data.sh ..."
source ./shell/produce_img_shell/select_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
select_data "mine"
if [ $? -ne 0 ]
then
	echo "选择定向数据失败."
	exit 1
fi

echo "产生挖掘数据完成."
date

echo "开始善后处理..."
###################################################################################
#		III.	 对生成的数据进行善后处理(替换HTML字符，传输到远程主机)
#

# 	5. 替换HTML字符
./shell/produce_img_shell/clear_html_char.sh 
if [ ${?} -ne 0 ]
then 
    echo "替换HTML字符失败!";
    exit 1;
fi;

#	6. 传输到远程机器
./shell/produce_img_shell/scp_to_remote.sh
if [ ${?} -ne 0 ]
then 
    echo "传输到远程机器失败！"
    exit 1;
fi;

echo "善后处理完成."
echo "产生数据完成."
date

