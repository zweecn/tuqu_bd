#!/bin/bash

down="data/download_info/mine.urls_to_download.20120813"
out="data/download_info/mine.urls_to_download.site"

#awk -F '\t' '{
#	print $2;
#}' ${down} | perl -lne '{
#	if ($_ =~ /[\.\/]([^\/]+?\.\w+)\//) {
#		print $1;
#	}
#}' | awk '{
#	cnt[$1]++;
#} END {
#	for (s in cnt) {
#		print s"\t"cnt[s];
#	}
#}' | sort -n -k2 -r > ${out}
#
awk -F '\t' '{
	if (index($1, "libdd.com")) {
		print $0;
	}
}' ${down} > ${out}.need_down
