#!/bin/bash

awk -F '\t' '{
#print $2;
	if (!match($2, /.*.diandian.com*/)) 
	{
		print $0;		
	}
}' data/merged > data/with_diandian.out

cat data/diandian_tag_parser >> data/with_diandian.out 
