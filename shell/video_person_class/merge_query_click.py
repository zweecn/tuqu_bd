#!/bin/env python
# coding=gbk

import urllib
import urllib2
import re
import os
import sys
import time
from urllib2 import URLError
'''
enum{
    TAB_SEARCH_START_POS=20,
    MOVIE_QUERY,
    SITCOM_QUERY,
    MUSIC_QUERY,
    ZONGHE_QUERY,
    QUYI_QUERY,
    ZONGYI_QUERY,
    YANCH_QUERY,
    ADVISE_QUERY,
    WUDAO_QUERY,
    MOFX_QUERY,
    ZIXUN_QUERY,
    SPORT_QUERY,
    JIAOCHEN_QUERY,
    YANGJIANG_QUERY,
    XIEZHEN_QUERY,
    TAB_SEARCH_END_POS
};
'''

query_type_dict={}
click_type_dict={}
alia_name_dict={}
fail_num=0;
ty_map={0:0,1:0,2:23,3:21,4:22,5:0,6:0,7:0,8:0,9:25,10:26,11:27,12:28,13:29,14:30,15:31,16:32,17:33,18:34, 19:35};

def read_url_once(url):
	try:
		req=urllib2.Request(url)
		res=urllib2.urlopen(req)
		lines = res.readlines()
	except:
		time.sleep(1)
		return None
	return lines

def read_url(url):
	lines = None;
	retry_num = 0;
	while lines == None:
		lines = read_url_once(url);
		if lines==None and retry_num < 2:
			retry_num += 1;
			continue;
		if lines==None and retry_num >= 2:
			return None;
		if lines != None:
			return lines;


def load_dict(qfname, cfname, type_num):

	fin = open(qfname, "r")
	for line in fin.readlines():
		l_s = line.strip().split("\t")
		if len(l_s) != type_num+1:
			print "no no !! %d\t%d" % (len(l_s) , int(type_num))
			continue;
		if l_s[0].find(".") >= 0:
			continue;
		query_type_dict[l_s[0]] = [];
		for i in range(0, type_num):
			#if i == 15:
			if i == 15 and int(l_s[i+1]) > 0:
				query_type_dict[l_s[0]].append(100)
			else:
				query_type_dict[l_s[0]].append(int(l_s[i+1]))
	fin.close()


	fin = open(cfname, "r")
	for line in fin.readlines():
		l_s = line.strip().split("\t")
		if len(l_s) != int(type_num)+1:
			continue;
		if l_s[0].find(".") >= 0:
			continue;
		click_type_dict[l_s[0]] = [];
		for i in range(0, type_num):
			#if i == 15:
			if i == 15 and int(l_s[i+1]) > 0:
				click_type_dict[l_s[0]].append(100)
			else:
				click_type_dict[l_s[0]].append(int(l_s[i+1]))
	fin.close()

def merge_data(type_num):
	for person in query_type_dict.keys():
		if not click_type_dict.has_key(person):
			click_type_dict[person] = query_type_dict[person]
		else:
			#体育类点击数据不准，先不使用
			click_type_dict[person][16] = 0
			for i in range(0,type_num):
				click_type_dict[person][i] += query_type_dict[person][i]
				click_type_dict[person][i] /= 2;
				#click_type_dict[person][i] = query_type_dict[person][i]
			#曲艺类的人物，音乐需求小于10则屏蔽音乐需求,防止相声被当做音乐
			if click_type_dict[person][9] > 50 and click_type_dict[person][2] < 10:
				click_type_dict[person][2] = 0;

def filter_data_by_resnum(type_num):
	global fail_num
	for person in click_type_dict.keys():
		for i in range(9,type_num):
			ty_field = click_type_dict[person][i];
			if(ty_field > 0):
				url="http://video.baidu.com/v?word=%s&ct=335544320&ty=%d&nf=1" % (re.sub('[ 	]+', '+',person), ty_map[i]);
				lines = read_url(url);
				disp_num=0
				if lines == None:
					fail_num += 1
					print "failed: %s\t%d\t%d\t%s"%(person, disp_num, i, url)
					click_type_dict[person][i] = 0;
					continue;
				for line in lines:
					m=re.findall("<dispnum>(.*?)</dispnum>", line)
					if m is not None:
						for j in m:
							disp_num = int(j)
							print "success: %s\t%d\t%d\t%s"%(person, disp_num, i, url)
							break;
				if disp_num < 40:
					print person + str(i) + "set to zero" + str(url)
					click_type_dict[person][i] = 0;

	'''将只有作品需求的人物去除'''
	for person in click_type_dict.keys():
		sum=0;
		for i in range(9,type_num):
			ty_field = click_type_dict[person][i];
			if(ty_field > 0):
				sum+=1
		if sum == 0:
			click_type_dict[person][2]=0;
			click_type_dict[person][3]=0;
			click_type_dict[person][4]=0;


def process_data_by_cfg(fname1, fname2, fname3, type_num):
	#将配置的不出tab的人物类型.
	fin = open(fname1, "r")
	for line in fin.readlines():
		l_s = line.strip().split("\t")
		if(len(l_s) != 2):
			continue;
		if l_s[0] in click_type_dict.keys() and int(l_s[1]) < type_num  and int(l_s[1]) > 0:
			click_type_dict[l_s[0]][int(l_s[1])] = 0;
	fin.close()
	#不出tab的人物进行屏蔽
	fin = open(fname2, "r")
	for line in fin.readlines():
		l_s = line.strip().split("\t")
		if(len(l_s) != 1):
			continue;
		if l_s[0] in click_type_dict.keys():
			del click_type_dict[l_s[0]];
	fin.close()
	#增加某个人的配置
	fin = open(fname3, "r")
	for line in fin.readlines():
		l_s = line.strip().split("\t")
		if(len(l_s) != 3):
			continue;
		if int(l_s[1]) >= type_num  and int(l_s[1]) < 0:
			continue;
		if int(l_s[2]) > 100  and int(l_s[2]) < 0:
			continue;
		if l_s[0] not in click_type_dict.keys():
			click_type_dict[l_s[0]] = [];
		for i in range(0, type_num):
			click_type_dict[l_s[0]].append(0)
		click_type_dict[l_s[0]][int(l_s[1])] = 100 - int(l_s[2]);
	fin.close()


			
#将人物重名处理
#第一列为目标人名，第二列为别名
def alia_name(fname, type_num):
	fin = open(fname, "r")
	for line in fin.readlines():
		l_s = line.strip().split("\t")
		if l_s[0] in click_type_dict.keys() and l_s[1] not in click_type_dict.keys():
			click_type_dict[l_s[1]] = [];
			click_type_dict[l_s[1]].extend(click_type_dict[l_s[0]]);
			alia_name_dict[l_s[1]] = l_s[0]
	fin.close()

def output_data(fname, type_num):
	fou = open(fname, "w")
	for person in click_type_dict.keys():
		output_str = person;
		if person in alia_name_dict.keys():
			output_str = output_str + "\t" + alia_name_dict[person]
		else:
			output_str = output_str + "\t"
		for i in range(0,type_num):
			output_str = output_str + "\t" + str(click_type_dict[person][i])
		output_str = output_str + "\n"
		fou.write(output_str);
	fou.close()


if __name__=="__main__":
	if len(sys.argv) != 5:
		sys.exit(1)
	else:
		load_dict(sys.argv[1], sys.argv[2], int(sys.argv[4]))
		merge_data(int(sys.argv[4]))
		process_data_by_cfg("./conf/pcategory_filter.txt", "./conf/person_filter.txt", "./conf/add_person.txt", int(sys.argv[4]))
		filter_data_by_resnum(int(sys.argv[4]))
		alia_name("./conf/alia_names.txt", int(sys.argv[4]))
		output_data(sys.argv[3], int(sys.argv[4]))
		print "fail_num:%d" % (fail_num)
		if fail_num > 100:
			sys.exit(1)
