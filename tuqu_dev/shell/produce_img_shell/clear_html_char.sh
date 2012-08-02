#/bin/bash

# 替换掉非法字符
###################################################################################
#	基本数据目录
# 	filename 		程序正在执行的脚本文件名
# 	temp			程序中间生成的临时文件目录
#	input			主程序的原始输入目录，手工提供的数据
#	swap			本脚本或者其他脚本的输入/输出文件目录，供脚本之间传递输入输出
#	output			主程序的输出文件
filename=`echo $0 | awk -F'[./]' '{ print $(NF - 1)}'`
temp="./data/temp/"${filename}
input="./data/input"
swap="./data/swap"
output="./data/output"
###################################################################################

# 输入文件
index=${output}"/data_for_tuqu/data_index."`date +%Y%m%d`
# 临时文件
tmp=${temp}.index
# 非法的HTML字符集合
htm_char=(\&yuml\; \&yen\; \&Yacute\; \&yacute\; \&Uuml\; \&uuml\; \&uml\; \&Ugrave\; \&ugrave\; \&Ucirc\; \&ucirc\; \&Uacute\; \&uacute\; \&times\; \&THORN\; \&thorn\; \&szlig\; \&sup3\; \&sup2\; \&sup1\; \&shy\; \&sect\; \&reg\; \&raquo\; \&pound\; \&plusmn\; \&para\; \&Ouml\; \&ouml\; \&Otilde\; \&otilde\; \&Oslash\; \&oslash\; \&ordm\; \&ordf\; \&Ograve\; \&ograve\; \&Ocirc\; \&ocirc\; \&Oacute\; \&oacute\; \&Ntilde\; \&ntilde\; \&not \&nbsp\; \&middot\; \&micro\; \&macr\; \&lt\; \&laquo\; \&Iuml\; \&iuml\; \&iquest\; \&Igrave\; \&igrave\; \&iexcl\; \&Icirc\; \&icirc\; \&Iacute\; \&iacute\; \&gt\; \&frac34\; \&frac14\; \&frac12\; \&Euml\; \&euml\; \&ETH\; \&eth\; \&Egrave\; \&egrave\; \&Ecirc\; \&ecirc\; \&Eacute\; \&eacute\; \&divide\; \&deg\; \&curren\; \&copy\; \&cent\; \&cedil\; \&Ccedil\; \&ccedil\; \&brvbar\; \&Auml\; \&auml\; \&Atilde\; \&atilde\; \&Aring\; \&aring\; \&amp\; \&Agrave\; \&agrave\; \&AElig\; \&aelig\; \&acute\; \&Acirc\; \&acirc\; \&Aacute\; \&aacute\;)
# 替换为的字符
replace_char=""

echo "开始替换非法的HTML字符..."

cp ${index} ${tmp}
if [ $? -ne 0 ]
then
	echo -e "${index}文件不存在."
	exit 1
fi

for htm in ${htm_char[@]}
do
	sed -i -e "s#${htm}#${replace_char}#g" ${tmp}
done

mv ${tmp} ${index}
if [ $? -ne 0 ]
then
	echo -e "重命名${tmp}失败."
	exit 1
fi

echo "HTML非法字符的替换完成，输出文件为 ${index}"
