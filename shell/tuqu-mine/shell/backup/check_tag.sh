#!/bin/bash


awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		at[$1] = 1;
	} 
	else
	{
		str = $3"$$"$4;
		gsub(/\//, "", str);
		out_str = $2"\t"$5"\t"$6"\t"1;
		n = split(str, a, "\\$\\$");
		delete b;
		for(i in a)
		{
			if(a[i] == "")
			{
				continue;
			}
			if(!(a[i] in at))
			{
				continue;
			}
			if(!(a[i] in b))
			{
				cnt[a[i]]++;
				print $2 > "tmp";
				b[a[i]] = 1;
			}
		}
	}
} END {
	for(i in cnt)
	{
		print i"\t"cnt[i];
		sum += cnt[i];
	}
	print sum;
}' conf/humor ./data/output > check_out
if [ ${?} -ne 0 ]
then
	echo "for pinggu failed!"
	exit 1
fi

LC_ALL=C sort tmp | uniq | wc -l 
