#!/bin/bash


# 明星
# 搞笑
# 服装
# 风景
# 时尚
# 萌宠
# 家居
awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else
	{
		if(a[$1])
		{
			print $0"\t"a[$1];
		}
	}
}' scand_tag_1  ti
