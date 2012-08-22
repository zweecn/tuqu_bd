#!/bin/bash

temp="./data/temp/"`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`

input="./data/source_valid"
output="./data/source_valid.rm_useless"

### 1. segment
awk -F'	' '{
	printf("%s\t%s\t%s\t", $1, $2, $NF);
	for(i = 4; i < NF; i++)
	{
		printf(" %s | ", $i);
	}
	printf("\n");
}' ${input} > ${temp}.in
if [ $? -ne 0 ]
then
	echo "prepare failed"
	exit 1
fi

./bin/segment -c 4 -i ${temp}.in -o ${temp}.seg ./conf/
if [ ${?} -ne 0 ]
then
	echo "segment failed!"
	exit 1
fi

## 2. calc idf
awk -F'	' '{
	delete b;
	for(i = 5; i <= NF; i++)
	{
		if(!($i in b))
		{
			a[$1"\t"$i]++;
			b[$i] = 1;
		}
	}
} END {
	for(i in a)
	{
		print i"\t"a[i];
	}
}' ${temp}.seg > ${temp}.freq
if [ ${?} -ne 0 ]
then
	echo "calc failed!"
	exit 1
fi

awk -F'	' '{
	a[$1]++
} END {
	for(i in a)
	{
		print i"\t"a[i];
	}
}' ${temp}.in > ${temp}.site_freq
if [ ${?} -ne 0 ]
then
	echo "site freq"
	exit 1
fi

## 3. mark high idf words
awk -F'	' 'BEGIN { OFS = "\t";}
{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else if(FILENAME == ARGV[2])
	{
		b[$1"\t"$2] = $3;
	}
	else
	{
		for(i = 5; i <= NF; i++)
		{
			$i = $i"("b[$1"\t"$i] / a[$1]")";
		}
		print;
	}
}' ${temp}.site_freq ${temp}.freq ${temp}.seg > ${temp}.seg_freq
if [ ${?} -ne 0 ]
then
	echo "mark failed!"
	exit 1
fi

### 4. check if marked words useless
awk -F'	' 'BEGIN { OFS = "\t";}
{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else if(FILENAME == ARGV[2])
	{
		b[$1"\t"$2] = $3;
	}
	else
	{
		for(i = 5; i <= NF; i++)
		{
			if(b[$1"\t"$i] / a[$1] > 0.7)
			{
				str = $i;
				for(j = i + 1; j <= NF; j++)
				{
					if(b[$1"\t"$j] / a[$1] > 0.7)
					{
						str = str""$j;
					}
					else
					{
						break;
					}
				}
				c[$1"\t"str]++;
				i = j - 1;
			}
		}
	}
} END {
	for(i in c)
	{
		print i"\t"c[i];
	}
}' ${temp}.site_freq ${temp}.freq ${temp}.seg > ${temp}.pattern
if [ ${?} -ne 0 ]
then
	echo "mark failed!"
	exit 1
fi

## 4. select high idf words
awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else
	{
		if(($3 / a[$1]) > 0.7)
		{
			next;
		}
		print;
	}
}' ${temp}.site_freq ${temp}.freq > ${temp}.high_freq
if [ ${?} -ne 0 ]
then
	echo "get high freq failed!"
	exit 1
fi

## 4. move useless words
awk -F'	' 'BEGIN { OFS = "\t";}
{
	if(FILENAME == ARGV[1])
	{
		a[$1"\t"$2] = $3;
	}
	else
	{
		str = "";
		for(i = 5; i <= NF; i++)
		{
			if($i == "|" || $1"\t"$i in a)
			{
				str = str" "$i;
			}
		}
		gsub(/[ ]+/, " ", str);
		$4 = str;
		print;
	}
}' ${temp}.high_freq ${temp}.seg > ${temp}.rm_useless
if [ ${?} -ne 0 ]
then
	echo "mark failed!"
	exit 1
fi


## 5. output
rm -rf ${output}.bak
mv ${output} ${output}.bak
cp ${temp}.rm_useless ${output}

exit 0

