tuqu_baidu
==========

tuqu for baidu部署步骤:
1. 拷贝所有文件到目标机器
2. 修改目标机的环境变量，增加一行 export LC_ALL=zh_CN.gbk 并使得环境变量生效
3. 每次执行 ./shell/produce_img_shell/produce_data_control.sh 即可选择需要的数据
4. 日志输出到 ./log/produce_img.log

代码结构:

Data_Produce |-- produce_data_control.sh
					|-- select_data.sh
					|-- clear_html_char.sh

之后每天定时执行./shell/produce_img_shell/produce_data_control.sh

常用目录: 
	temp="./data/temp/"							存放临时文件，每个临时文件以执行脚本名开头
	input="./data/input/"						存放输入文件
	swap="./data/swap/"							存放交换文件，由脚本之间进行数据交换
	output="./data/output/"						存放输出文件
	backup_dir="data/input/used_objs_backup"	备份每天已经灌库的图片数据，以便下一次不会选择这些数据

输入文件:	
	dingxiang_final_objs=${swap}"dingxiang_final_objs_data"		定向数据最后的数据
	mine_final_objs=${swap}"mine_final_objs_data"				挖掘数据最后的数据
	used_objs=${input}"/used_objs"								已经使用过的图片数据

输出文件:
	out=${output}"/data_for_tuqu/"

配置文件:
	total_type_demand="conf/total_type_demand"					每天每个大类的需求数量 格式: type \t amount
	dx_vs_mine="conf/dingxiang_vs_mine"							定向数据和挖掘数据的比值 格式: num \t num 
	dingxiang_type_demand_amount="conf/dingxiang_type_demand"	根据数据所占比例生成的定向数据需求 格式: type \t demand
	mine_type_demand_amount="conf/mine_type_demand"				根据数据所占比例生成的挖掘数据需求 格式: type \t demand
