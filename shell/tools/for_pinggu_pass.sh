#!/bin/bash
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/tmp/"${filename}

dingxiang="data/swap/dingxiang_final_objs_data.without_path"
mine="data/swap/mine_final_objs_data.without_path"
dingxiang_other4="../tuqu_baidu_other4/data/swap/dingxiang_final_objs_data.without_path"
mine_other4="../tuqu_baidu_other4/data/swap/mine_final_objs_data.without_path"

output_dir="./data/tmp/pinggu"

rm -rf ${output_dir}
mkdir -p ${output_dir}

echo "Begin generate the tags file for pingu..."

#perl -lne '{
#	if ($_ =~ /(\w+\.\w+)\/.+?(\w+\.\w+)\//) {
#		print $_."\t".$1;
#	}
#}' $mine $mine_other4 > data/temp/mine_with_site

#awk -F '\t' -v out="${output_dir}" '{
#	if ($3 == "") {
#		print;
#		next;
#	}
#	if (mark[$1]) {
#		next;
#	}
#	mark[$1] = 1;
#	gsub(",", "$$", $3);
#	print $1 "\t" $3 "\t" $2 "\t" 1 "\t" $NF"\tno_desc"; 
#}' data/temp/mine_with_site > data/temp/mine_pass_pinggu.txt 


#perl -lne '{
#	if ($_ =~ /(\w+\.\w+)\/.+?(\w+\.\w+)\//) {
#		print $_."\t".$1;
#	}
#}' $dingxiang $dingxiang_other4 > data/temp/dingxiang_with_site

#awk -F '\t' '{
#	if (FILENAME == ARGV[1]) {
#		if ($1 != "") {
#			desc[$1] = $4;
#			chanel[$1] = $6;
#		}
#	} else {
#		if (!mark[$1]) {
#			mark[$1] = 1;
#			gsub(",", "$$", $3);
#			print $1 "\t" $3 "\t" $2 "\t" 1 "\t" $NF"\t"(desc[$1]=="" ? "no_desc" : desc[$1]); 
#		}
#	}
#}' data/input/objs_all data/temp/dingxiang_with_site > data/temp/dingxiang_pass_pinggu.txt

awk -F '\t' '{
	if (!mark[$1]) {
		mark[$1] = 1;
		print;
	}
}' data/temp/dingxiang_pass_pinggu.txt data/temp/mine_pass_pinggu.txt > for_pinggu.txt 


echo "Finish generated."
