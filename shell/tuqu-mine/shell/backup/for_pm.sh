#!/bin/bash


# ����
# ��Ц
# ��װ
# �羰
# ʱ��
# �ȳ�
# �Ҿ�
awk -F'	' '{
	if(FILENAME == ARGV[1])
	{
		a[$1] = $2;
	}
	else
	{
		if(a[$1])
		{
			print $0"\t"a[$1];
		}
	}
}' scand_tag_1  ti
