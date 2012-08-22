#!/bin/bash

set -x

source conf/common.conf

#mysql_path=/home/video/database/mysql
mysql_path=/home/work/mysql/bin/mysql
mysql_host=10.81.50.206

human_name_server="ftp://tc-video-bg01.tc/home/video/video_class/full_video_word/data/type_word/人物作品.txt"

TYPE_NUM=20

##0.0 查看上一次脚本是否已经运行完毕
if [ -r ./temp/get_person_type.flag ]
then
    send_error "WARNING:get_person_type.sh is still running"
    exit 1
fi
touch ./temp/get_person_type.flag

mkdir -p ./data/backup

##1.0 点击系统导出query以及点击数据
rm -rf ./data/query_info.raw
rm -rf ./data/click_info.raw
for((i = 0; i < 10; i++))
do
	${mysql_path} -u root -h ${mysql_host} click_db --skip-column-names -e "select word, search_cnt from qwords_table${i}" >> ./data/query_info.raw
	if [ $? -ne 0 ]
	then
		send_error "点击系统导出query数据失败"
		rm -rf  ./temp/get_person_type.flag
		exit 1
	fi
	${mysql_path} -u root -h ${mysql_host} click_db --skip-column-names -e "select word, cnt, video_type from click_table${i}" >> ./data/click_info.raw
	if [ $? -ne 0 ]
	then
		send_error "点击系统导出click数据失败"
		rm -rf  ./temp/get_person_type.flag
		exit 1
	fi
done

awk -F'	' '{ a[$1] += $2; } END { for(i in a) { print i"\t"a[i]; }}' ./data/query_info.raw > ./data/query_info
if [ $? -ne 0 ]
then
	send_error "merge query info failed"
	rm -rf ./temp/get_person_type.flag
	exit 1
fi

awk -F'	' '{ a[$1"\t"$3] += $2; } END { for(i in a) { n = split(i, arr, "\t");  print arr[1]"\t"a[i]"\t"arr[2]; }}' ./data/click_info.raw > ./data/click_info
if [ $? -ne 0 ]
then
	send_error "merge click info failed"
	rm -rf ./temp/get_person_type.flag
	exit 1
fi

##2.0 更新人物词表
cp ./conf/human_name.txt ./data/backup/human_name.txt.$(date +%Y%m%d)
wget -O ./temp/human_name.txt ${human_name_server}
if [ $? -ne 0 ]
then
	send_error "合并新老人名数据失败"
	exit 1
fi
cut -d'	' -f 1 ./conf/human_name.txt ./temp/human_name.txt | sort | uniq > ./temp/human_name_merged.txt
if [ $? -ne 0 ]
then
	send_error "合并新老人名数据失败1"
	exit 1
fi
cp ./temp/human_name_merged.txt conf/human_name.txt

##3.0 query文本分析人物需求
./bin/get_name_record  ./conf/human_name.txt ./data/query_info > ./data/person_query.txt
if [ $? -ne 0 ]
then
    send_error "获取人名query失败"
	rm -rf ../temp/get_person_type.flag
	exit 1
fi

##person_query格式为：query \t 人名 \t frq
##person_query_type格式为： query \t 人名 \t frq \t query类型

cat ./data/person_query.txt | ./bin/jqtype > ./data/person_query_type.txt
sort -t'	' -k2,2 ./data/person_query_type.txt -T ./temp  > ./temp/tmp.txt
echo " " >> ./temp/tmp.txt
awk -v type_num=$TYPE_NUM -F '\t'  'BEGIN{
	person_name = "";
	for(i=0; i<type_num; ++i){
		type[i] = 0;
	}
}
{
	if(person_name != $2){
		sum=0;
		output_str = person_name;
		for(i in type){
			if(i != 1 && i != 0){
				sum+=type[i];
			}
		}
		for(i=0; i<type_num; ++i ){
			if(sum > 0){
				type[i] = int(type[i]*100/sum);
			}
			output_str = output_str"\t"type[i];
		}
		if(person_name != ""){
			print output_str;
		}
		for(i=0; i<type_num; ++i){
			type[i] = 0;
		}
		person_name = $2;
	}
	if($4 != 0 && $4 != 1 && $4 != 5 && $4 != 6 && $4 != 7 && $4 != 8 && $4 <type_num){
		type[$4]+=$3;
	}
}' ./temp/tmp.txt > ./data/person_type1.txt
if [ $? -ne 0 ]
then
	send_error "从query数据获取人名类型失败"
	exit 1
fi

##4.0 通过点击分析人物需求
##click_info 为 query \t cnt \t type
./bin/get_name_record  ./conf/human_name.txt ./data/click_info > ./data/person_click.txt
if [ $? -ne 0 ]
then
	send_error "获取人名query的点击数据失败"
	rm -rf ../temp/get_person_type.flag;
	exit 1
fi

##person_click文件格式为：query \t 人名 \t 次数 \t video_type
sort -t'	' -k2,2 ./data/person_click.txt -T ./temp  > ./temp/tmp.txt
echo " " >> ./temp/tmp.txt

awk -v type_num=$TYPE_NUM -F '\t' 'BEGIN{person_name = "";
	for(i=0; i<type_num; ++i){
		type[i] = 0;
	}
}
{
	if(person_name != $2){
		sum=0;
		output_str = person_name;
		for(i in type){
			if(i != 1 && i != 0){
				sum+=type[i];
			}
		}

		for(i=0; i<type_num; ++i ){
			if(sum > 0){
				type[i] = int(type[i]*100/sum);
			}
			output_str = output_str"\t"type[i];
		}

		if(sum > 0){
			print output_str;
		}

		for(i=0; i<type_num; ++i){
			type[i] = 0;
		}
		person_name = $2;
	}

	if($4 != 0 && $4 != 1 && $4 != 5 && $4 != 6 && $4 != 7 && $4 != 8 && $4<type_num){
		type[$4]+=$3;
	}
}' ./temp/tmp.txt > ./data/person_type2.txt
if [ $? -ne 0 ]
then
	send_error "获取点击的人名类型失败"
	rm -rf  ./temp/get_person_type.flag
	exit 1
fi

##5.0 合并query和点击两种方法得到的人物的需求分布
##~/python/bin/python merge_query_click.py  ./data/person_type1.txt  ./data/person_type2.txt ./temp/person_category.txt ${TYPE_NUM}
python ./shell/merge_query_click.py  ./data/person_type1.txt  ./data/person_type2.txt ./temp/person_category.txt ${TYPE_NUM}
if [ $? -ne 0 ]
then
    send_error "合并query和点击的类型信息失败!"
	rm -rf  ./temp/get_person_type.flag
	exit 1
fi

##过滤掉分类中只有一种需求的人物
awk -F '\t' 'BEGIN{OFS="\t"}{sum=0;for(i=3;i<=NF;i++){if($i>0) sum++; }if(sum>1) {print $0"\t""\t""\t""\t""\t""\t""\t"}}' ./temp/person_category.txt > ./temp/tmp.txt
if [ $? -ne 0 ]
then
	send_error "过滤人名列表失败"
	rm -rf  ./temp/get_person_type.flag
	exit 1

fi

## 5.1 和原有的merge：冲突的用新的替代旧的，否则直接加上；
## eg: 旧的:A/B/C; 新的：B1/C1/D ; =>  A/B1/C1/D;
old="./data/person_category.txt"
new="./temp/person_category.txt"
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		new_person[$1] = $0;
	} else {
		if (!($1 in new_person)) {
			print;
		}
	}
}' $new $old > ./temp/person_category.without_new
if [ $? -ne 0 ]
then
	send_error "合并旧数据失败"
	rm -rf  ./temp/get_person_type.flag
	exit 1

fi
cat ./temp/person_category.without_new >> $new

### 6.0 备份最近三十天的数据
mv ./data/person_category.txt ./data/backup/person_category.txt.$(date +%Y%m%d)
deadline=`date -d"30 days ago" +%Y%m%d`
for filename in `ls ./data/backup`
do
	file="./data/backup/$filename"
	date_time=`echo $filename | awk -F"." '{ print $NF}'`
	if [ ${date_time} -lt ${deadline} ]
	then
		rm -rf ${file}
	fi
done

cp ./temp/person_category.txt ./data/person_category.txt


### 7.0 传输到线上
#cp ./data/person_category.txt  /home/video/video_class/video_word/conf/type_word/

rm -rf  ./temp/get_person_type.flag
exit 0

