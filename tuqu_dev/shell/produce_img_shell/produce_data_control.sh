#!/bin/bash

### 生成可用数据源主控制脚本 产生今天的图片索引以便图趣灌库

echo "开始产生数据..."
date

### 1 合作（定向）数据
./shell/produce_img_shell/normalize_dingxiang_data.sh;
if [ ${?} -ne 0 ]
then 
    echo "定向数据格式化失败！";
    exit 1;
fi;

### 2 机器挖掘数据
./shell/produce_img_shell/normalize_mining_data.sh
if [ ${?} -ne 0 ]
then 
    echo "挖掘数据格式化失败！";
    exit 1;
fi;

### 3 合并
./shell/produce_img_shell/format_data.sh
if [ ${?} -ne 0 ]
then 
    echo "合并数据失败！";
    exit 1;
fi;

### 4. 选择数据
./shell/produce_img_shell/select_data.sh
if [ ${?} -ne 0 ]
then 
    echo "选择数据失败！";
    exit 1;
fi;

### 5. 替换HTML字符
./shell/produce_img_shell/clear_html_char.sh 
if [ ${?} -ne 0 ]
then 
    echo "替换HTML字符失败!";
    exit 1;
fi;

### 6. 传输到远程机器
./shell/produce_img_shell/scp_to_remote.sh
if [ ${?} -ne 0 ]
then 
    echo "传输到远程机器失败！"
    exit 1;
fi;

echo "产生数据完成."
date
