#!/bin/bash

###################################################################################
#
#	脚本功能: 
#		生成可用数据源主控制脚本 产生今天的图片索引以便图趣灌库
#	分3步骤进行:
#		I.		 生成定向的数据
#		II.		 生成挖掘的数据
#
###################################################################################

echo "=============================================================================="
echo "[开始]	开始产生数据..."
echo -e "[时间] `date`"
start_time=`date +%s`

rm -rf data/temp/*

###################################################################################
#
#	I.		 生成定向的数据
#
# 	1.	合作（定向）数据 第一步格式化
echo "[STEP 1] 提取定向数据 obj_url / from_url / tag ..."
./shell/produce_img_shell/normalize_dingxiang_data.sh;
if [ ${?} -ne 0 ]
then 
    echo "[错误]	定向数据格式化失败."
    exit 1;
fi

#	2.	进一步格式化定向数据，包括筛选和替换等等
echo "[STEP 2] 格式化定向数据 ..."
echo "	source format_data.sh ..."
source ./shell/produce_img_shell/format_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
format_data "dingxiang"
if [ $? -ne 0 ]
then
	echo "[错误]	进一步格式化定向数据失败."
	exit 1
fi

echo "[FINISHED] 定向数据格式化完成."
end_dingxiang=`date +%s`
echo "[时间] `date` 定向数据处理耗时 $(($end_dingxiang - $start_time)) s"

###################################################################################
#
#	II.		 生成挖掘的数据
#
# 	1.	挖掘数据 第一步格式化
echo "[STEP 1] 提取挖掘数据 obj_url / from_url / tag ..."
./shell/produce_img_shell/normalize_mining_data.sh
if [ ${?} -ne 0 ]
then 
    echo "[错误]	挖掘数据格式化失败."
    exit 1;
fi

#	2.	进一步格式化挖掘数据，包括筛选和替换等等
echo "[STEP 2] 格式化挖掘数据 ..."
echo "	source format_data.sh ..."
source ./shell/produce_img_shell/format_data.sh
if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi
format_data "mine"
if [ $? -ne 0 ]
then
	echo "[错误]	进一步格式化定向数据失败."
	exit 1
fi

echo "[FINISHED] 格式化挖掘数据完成."
echo "[结束]格式化所有数据完成."
end_mine=`date +%s`
echo "[时间] `date` 挖掘数据处理耗时 $(($end_mine - $end_dingxiang)) s"
echo "[总耗时] $(($end_mine - $end_dingxiang)) s"
echo "=============================================================================="
