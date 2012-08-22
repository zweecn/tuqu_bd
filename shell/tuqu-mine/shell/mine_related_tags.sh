#!/bin/bash

temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
input="./data/source_valid"
person_name="./conf/person"

output="./data/tag_list"
show_tag="./data/tag_list_show"


# 目标tag：
# 1、美女帅哥  : 风格类型
# 		明星   : 人名
# 2、风景/旅行 : 近义词或者同义词表述、景点
# 3、趣味/搞笑 : 近义词或者同义词表述、描述具体类型、特定系列事情、
# 		猎奇   :
# 4、时尚/搭配/服饰 : 近义词或者同义词表述、风格类型、内容；
# 5、家具/装饰      : 风格类型、内容；


## 1. bi of tag
awk -F'	' '{
	n = split($NF, arr, "\\$\\$");

	delete hash;
	idx = 0;
	for(i = 1; i <= n; i++)
	{
		if(arr[i] in hash)
		{
			continue;
		}
		
		idx++;
		arr[idx] = arr[i];
		hash[arr[i]] = 1;
	}
	n = idx;
		
	for(i = 1; i <= n; i++)
	{
		si[arr[i]]++;
		for(j = i + 1; j <= n; j++)
		{
			bi[arr[i]"\t"arr[j]]++;
			bi[arr[j]"\t"arr[i]]++;
		}
	}
} END {
	for(i in bi)
	{
		print i"\t"bi[i] > "'${temp}.'bi";
	}
	for(i in si)
	{
		print i"\t"si[i] > "'${temp}.'si";
	}
}' ${input}
if [ ${?} -ne 0 ]
then
	echo "calc term freq failed!"
	exit 1
fi

## 2. support
awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else
	{
		print $0"\t"($3 / a[$2]);
	}
}' ${temp}.si ${temp}.bi > ${temp}.sp
if [ ${?} -ne 0 ]
then
    echo "calc sp failed!"
    exit 1
fi

## 3. tag type
awk -F'	' 'BEGIN {
	OFS = "\t";
	seed_tag[1] = "性感 清纯 长腿美女 男模 湿身写真 完美身材 美女 帅哥 明星";
	seed_tag[2] = "风景	旅行 旅游 景色 美景 鼓浪屿 马尔代夫 西藏 丽江海边 城堡 沙滩 城市 森林 沙漠 草原";
	seed_tag[3] = "趣味 恶搞 搞笑 趣图 囧 雷人可爱 萌宠 荤段子 动态 萌猫 冷笑话 凡客体 方舟子体 邪恶小漫画 凤姐";
	seed_tag[4] = "服饰 时装 搭配 潮流 服饰 欧美 复古 日系 韩系 连衣裙 T恤 高跟鞋 婚纱";
	seed_tag[5] = "欧式 客厅 卧室 宴会厅 书桌 卫浴 家具 家居";
	seed_tag[6] = "美食 菜谱 甜食 饮品 主食 川菜 粤菜 湘菜 烘焙 微波炉 红烧 拔丝 蛋糕 巧克力 冰淇淋 布丁 三杯鸡";
    seed_tag[7] = "摄影 映像 照片 照相 人物 静物 LOMO 唯美 清新 猫 胡同 老上海 婚纱摄影";
    seed_tag[8] = "艺术设计 创意 设计 DESIGN 平面设计 包装设计 广告设计 产品设计 建筑设计 雕塑 梵高 深泽直人 贝律铭 扎哈.哈迪德 配色 海报 文化 环保 design";
    seed_tag[9] = "动漫游戏 动画 漫画 插画 游戏 COSPLAY cosplay 火影忍者 灌篮高手 银魂 暗黑 魂斗罗 半条命";
    seed_tag[10]="美妆造型 美容/美发 侧重审美 美容 妆容 美发 化妆 妆发 美妆 美瞳 唇 美发 美甲 护肤 眼妆";
	level = 1;

	for(i = 6; i <= 10; i++)
	{
		n = split(seed_tag[i], arr, " ");
		for(j in arr)
		{
			key[arr[j]] = i;
		}
	}
} {
	if(($1 in key) && $3 >= 50)
	{
		$4 *= 1000;
		if($4 > 500)
		print key[$1]"\t"$0;
	}
}' ${temp}.sp | sort -t'	' -r -n -k5,5 | sort -t'	' -s -k1,1 > ${temp}.type
if [ ${?} -ne 0 ]
then
	echo "calc tag type failed!"
	exit 1
fi

awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else
	{
		print $3"\t"a[$3]"\t"$1;
	}
}' ${temp}.si ${temp}.type | sort -t'	' -r -n -k2,2 | sort -t'	' -s -n -k3,3 | uniq > ${temp}.show
if [ ${?} -ne 0 ]
then
	echo "filt tag type failed!"
	exit 1
fi

## 4. high freq tag
awk -F'	' '{
	if($2 > 50)
	{
		print;
	}
}' ${temp}.si > ${temp}.high_freq
if [ ${?} -ne 0 ]
then
	echo "calc high freq tag failed!"
	exit 1
fi

## output
rm -rf ${output}.bak
mv ${output} ${output}.bak
cp ${temp}.si ${output}

rm -rf ${show_tag}.bak
mv ${show_tag} ${show_tag}.bak
cp ${temp}.show ${show_tag}

exit 0

