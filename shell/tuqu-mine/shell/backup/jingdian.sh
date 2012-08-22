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
				print str > "rela"
				b[a[i]] = 1;
			}
		}
}
} END {
	for(i in cnt)
	{
		print i"\t"cnt[i];
		sum+=cnt[i];
	}
	print sum;
}' ./conf/area ./data/output.thumb > o
##}' ./conf/person ./data/output.thumb > o

awk -F'	' '{
	str = $1;
	gsub(/\//, "", str);
	n = split(str, a, "\\$\\$");
	delete b;
	for(i in a)
	{
		if(a[i] == "")
		{
			continue;
		}
		if(!(a[i] in b))
		{
			cnt[a[i]]++;
			b[a[i]] = 1;
		}
	}
} END {
	for(i in cnt)
	{
		print i"\t"cnt[i];
	}
}' rela > oo
