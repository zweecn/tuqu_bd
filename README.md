tuqu_baidu
==========

tuqu for baidu������:
1. ���������ļ���Ŀ�����
2. �޸�Ŀ����Ļ�������������һ�� export LC_ALL=zh_CN.gbk ��ʹ�û���������Ч
3. ÿ��ִ�� ./shell/produce_img_shell/produce_data_control.sh ����ѡ����Ҫ������
4. ��־����� ./log/produce_img.log

����ṹ:

Data_Produce |-- produce_data_control.sh
					|-- select_data.sh
					|-- clear_html_char.sh

֮��ÿ�춨ʱִ��./shell/produce_img_shell/produce_data_control.sh

����Ŀ¼: 
	temp="./data/temp/"							�����ʱ�ļ���ÿ����ʱ�ļ���ִ�нű�����ͷ
	input="./data/input/"						��������ļ�
	swap="./data/swap/"							��Ž����ļ����ɽű�֮��������ݽ���
	output="./data/output/"						�������ļ�
	backup_dir="data/input/used_objs_backup"	����ÿ���Ѿ�����ͼƬ���ݣ��Ա���һ�β���ѡ����Щ����

�����ļ�:	
	dingxiang_final_objs=${swap}"dingxiang_final_objs_data"		����������������
	mine_final_objs=${swap}"mine_final_objs_data"				�ھ�������������
	used_objs=${input}"/used_objs"								�Ѿ�ʹ�ù���ͼƬ����

����ļ�:
	out=${output}"/data_for_tuqu/"

�����ļ�:
	total_type_demand="conf/total_type_demand"					ÿ��ÿ��������������� ��ʽ: type \t amount
	dx_vs_mine="conf/dingxiang_vs_mine"							�������ݺ��ھ����ݵı�ֵ ��ʽ: num \t num 
	dingxiang_type_demand_amount="conf/dingxiang_type_demand"	����������ռ�������ɵĶ����������� ��ʽ: type \t demand
	mine_type_demand_amount="conf/mine_type_demand"				����������ռ�������ɵ��ھ��������� ��ʽ: type \t demand
