#!/bin/bash

img="data/swap/objs.not_exist"

awk -F '\t' '{
	print $1;	
}' ${img} | tar -zcvf img.tar.gz 
