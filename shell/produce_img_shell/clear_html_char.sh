#/bin/bash

# �滻���Ƿ��ַ�
#####################################################################################
#	��������Ŀ¼
# 	filename 		��������ִ�еĽű��ļ���
# 	temp			�����м����ɵ���ʱ�ļ�Ŀ¼
#	input			�������ԭʼ����Ŀ¼���ֹ��ṩ������
#	swap			���ű����������ű�������/����ļ�Ŀ¼�����ű�֮�䴫���������
#	output			�����������ļ�
#	today			��������ڣ���ʽ�������� "20120802"
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}.${prefix}
input="./data/input"
swap="./data/swap/"${prefix}
output="./data/output"
today=`date +%Y%m%d`
####################################################################################

# �����ļ�
index_dingxiang=${output}"/data_for_tuqu/data_index.dingxiang."${today}
index_mine=${output}"/data_for_tuqu/data_index.mine."${today}

# �Ƿ���HTML�ַ�����
htm_char=(\&yuml\; \&yen\; \&Yacute\; \&yacute\; \&Uuml\; \&uuml\; \&uml\; \&Ugrave\; \&ugrave\; \&Ucirc\; \&ucirc\; \&Uacute\; \&uacute\; \&times\; \&THORN\; \&thorn\; \&szlig\; \&sup3\; \&sup2\; \&sup1\; \&shy\; \&sect\; \&reg\; \&raquo\; \&pound\; \&plusmn\; \&para\; \&Ouml\; \&ouml\; \&Otilde\; \&otilde\; \&Oslash\; \&oslash\; \&ordm\; \&ordf\; \&Ograve\; \&ograve\; \&Ocirc\; \&ocirc\; \&Oacute\; \&oacute\; \&Ntilde\; \&ntilde\; \&not \&nbsp\; \&middot\; \&micro\; \&macr\; \&lt\; \&laquo\; \&Iuml\; \&iuml\; \&iquest\; \&Igrave\; \&igrave\; \&iexcl\; \&Icirc\; \&icirc\; \&Iacute\; \&iacute\; \&gt\; \&frac34\; \&frac14\; \&frac12\; \&Euml\; \&euml\; \&ETH\; \&eth\; \&Egrave\; \&egrave\; \&Ecirc\; \&ecirc\; \&Eacute\; \&eacute\; \&divide\; \&deg\; \&curren\; \&copy\; \&cent\; \&cedil\; \&Ccedil\; \&ccedil\; \&brvbar\; \&Auml\; \&auml\; \&Atilde\; \&atilde\; \&Aring\; \&aring\; \&amp\; \&Agrave\; \&agrave\; \&AElig\; \&aelig\; \&acute\; \&Acirc\; \&acirc\; \&Aacute\; \&aacute\;)
# �滻Ϊ���ַ�
replace_char=""

echo "��ʼ�滻�Ƿ���HTML�ַ�..."

for htm in ${htm_char[@]}
do
	sed -i -e "s#${htm}#${replace_char}#g" ${index_dingxiang}
	sed -i -e "s#${htm}#${replace_char}#g" ${index_mine}
done

echo "HTML�Ƿ��ַ����滻��ɣ�����ļ�Ϊ ${index_mine} �� ${index_dingxiang}"
