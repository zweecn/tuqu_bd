#!/bin/bash


#perl -lne '{
#	if ($_ =~ /(^[(\d+)(\s+)]+)([(\w+)(\s+)]+?)(\d.*$)/) {
#		print $2;
#		print $3;
#	}
#}' data/temp/o > data/temp/o1

#awk -F '[\t(echo)]' '{
#	print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7;
#}' data/temp/o

rm -rf data/temp/o1
awk -F '\t' 'BEGIN{
	ORS = "";
	OFS = ",";
}{
	for (i=0; i<NF; i++) {
#		print $i;
		printf $i;
	}
	print "\n";
}' data/temp/o > data/temp/o1

