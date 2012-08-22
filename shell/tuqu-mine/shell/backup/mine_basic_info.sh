#!/bin/bash

#set -x

## 1. 
# {album_title, album_desc, album_type, album_tag}
# {page_title, title, tag, ctnt, mypos, alt, keyword, other}


#from_url_pattern[1]='http://huaban.com/pins/1105742/'
#from_url_pattern[2]='http://www.mishang.com/pin/4f5b21341d41c8529b0011d5/'
#from_url_pattern[3]='http://www.woxihuan.com/32196495/1339480383080740.shtml'
#from_url_pattern[4]='http://zhan.renren.com/dxscyjm?page=1&from=pages'
#from_url_pattern[5]='http://www.tuita.com/tagpage/%E7%BE%8E%E5%A5%B3/selected'
#from_url_pattern[6]='http://www.topit.me/item/10684867£»http://topit.me/album/411668/item/3160671'
#from_url_pattern[7]='http://www.xiachufang.com/recipe/11051/'
#from_url_pattern[8]='http://www.ycy8.net/2011_6178.html'
#from_url_pattern[9]='http://www.yupoo.com/photos/btbtshu/80089917/'
#from_url_pattern[10]='http://tuchong.com/45206/1504445/'

from_url_pattern[1]='http://huaban.com/pins/'
from_url_pattern[2]='http://www.mishang.com/pin/'
from_url_pattern[3]='http://www.woxihuan.com//.shtml'
from_url_pattern[4]='http://zhan.renren.com/dxscyjm?page=1&from=pages'
from_url_pattern[5]='http://www.tuita.com/tagpage/'
from_url_pattern[6]='http://topit.me/item/'  #http://topit.me/album/411668/item/3160671'
from_url_pattern[7]='http://www.xiachufang.com/recipe/'
from_url_pattern[8]='http://www.ycy8.net/_.html'
from_url_pattern[9]='http://www.yupoo.com/photos/'
from_url_pattern[10]='http://tuchong.com///'

index[1]=1
index[2]=1
index[3]=0
index[4]=1
index[5]=1
index[6]=1
index[7]=1
index[8]=0
index[9]=1
index[10]=0



# 1. 
rm -rf output
for((i = 1; i <= 10; i++))
do
	if [ ${i} -eq 4 ]
	then
		continue
	fi
	file=`echo ${from_url_pattern[i]} | awk -F'/' '{ print $3}'`
	echo ${file}"   "${from_url_pattern[i]}
	awk -F'	' 'BEGIN { pt = "'${from_url_pattern[i]}'"; gsub(/[0-9]/, "", pt);}	
	{
		if('${index[i]}' == 1)
		{
			if(index($2, "'${from_url_pattern[i]}'"))
			{
				print;
			}
		}
		else
		{
			furl = $2;
			gsub(/[0-9]/, "", furl);
			if(furl == pt)
			{
				print;
			}
		}
	}' "./data/assite/"${file} >> output
	if [ ${?} -ne 0 ]
	then
		echo "[$0] parse ${file} failed!"
		exit 1
	fi
done
