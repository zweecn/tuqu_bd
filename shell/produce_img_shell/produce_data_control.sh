#!/bin/bash
## 产生今天的图片索引以便图趣灌库

### 1. 生成本地路径
#ssh img@jx-apptest-img04.vm "cd /home/img/shiym/dingxiang/work/client && ./format_path_jinsong.sh";
#if [ ${?} -ne 0 ]
#then 
#    echo "远程生成图片路径数据失败！";
#    exit 1;
#fi;
### 2. 下载路径index
#scp img@jx-apptest-img04.vm:/home/img/shiym/dingxiang/work/client/formated_urls_jinsong/objs_local_path data/objs_local_path
#if [ ${?} -ne 0 ]
#then
#    echo "下载远程生成的图片路径数据失败!";
#    exit 1;
#fi;

############################################################################
### 1-2. 另外的脚本完成1-2步骤 产生百度服务器的image地址,
# 		也可以在开始的时候运行初始化
#./shell/produce_img_shell/gen_baidu_server_img_path.sh 


############################################################################
### 3. 生成可用数据源
############################################################################
echo "开始产生数据..."

## 3.1 合作（定向）数据
./shell/produce_img_shell/normalize_dingxiang_data.sh;
if [ ${?} -ne 0 ]
then 
    echo "定向数据格式化失败！";
    exit 1;
fi;

## 3.2 机器挖掘数据
./shell/produce_img_shell/normalize_mining_data.sh
if [ ${?} -ne 0 ]
then
    echo "挖掘数据格式化失败！";
    exit 1;
fi;

## 3.3 格式化定向数据
./shell/produce_img_shell/format_dingxiang.sh
if [ ${?} -ne 0 ]
then 
    echo "合并数据失败！";
    exit 1;
fi;

## 3.4 格式化挖据数据
./shell/produce_img_shell/format_mine.sh
if [ ${?} -ne 0 ]
then 
    echo "合并数据失败！";
    exit 1;
fi;

############################################################################
### 4. 选择数据
############################################################################
echo "选择数据..."

./shell/produce_img_shell/select_data.sh
if [ ${?} -ne 0 ]
then 
    echo "选择数据失败！";
    exit 1;
fi;

############################################################################
# 5. 替换HTML字符
############################################################################
echo "整理非法HTML字符..."
./shell/produce_img_shell/clear_html_char.sh 
if [ ${?} -ne 0 ]
then 
    echo "替换HTML字符失败!";
    exit 1;
fi;

############################################################################
# 6. 传输到远程机器
############################################################################
echo "传输数据..."
./shell/produce_img_shell/scp_to_remote.sh
if [ ${?} -ne 0 ]
then 
    echo "传输到远程机器失败！"
    exit 1;
fi;
