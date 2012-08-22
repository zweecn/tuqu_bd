set -x

# hadoop
HADOOP_HOME=".."

#mapper和reduce 程序
MAPPER="./mapper_tag_parser.sh"
REDUCER="cat"
DICT="./sitedict"

INPUT_PATH="/user/ns-image/urlselector.20120525_build4/dump_data/"
#INPUT_PATH="/user/ns-image/db/jinsong_test/test_hadoop_input"
OUTPUT_PATH="/user/ns-image/db/jinsong_test/diandian_tag_parser"
CONF_PATH="/user/ns-image/db/jinsong_test/conf/"

#设置mapper和reducer节点数目
MAPPER_NUM=500
REDUCER_NUM=1

#job name
JOB_NAME="jinsong_hadoop_tag_paser"

${HADOOP_HOME}/bin/hadoop fs -rmr $OUTPUT_PATH
${HADOOP_HOME}/bin/hadoop fs -mkdir $CONF_PATH

${HADOOP_HOME}/bin/hadoop fs -copyFromLocal wdbdtools.tar.gz ${CONF_PATH}/wdbdtools.tar.gz

${HADOOP_HOME}/bin/hadoop \
	jar ../contrib/streaming/hadoop-2-streaming.jar \
	-D mapred.job.priority='HIGH' \
	-D mapred.job.name=$JOB_NAME \
	-D mapred.map.tasks=$MAPPER_NUM \
	-D mapred.reduce.tasks=$REDUCER_NUM \
	-mapper $MAPPER \
	-reducer $REDUCER \
	-input $INPUT_PATH \
	-output $OUTPUT_PATH \
	-file $MAPPER \
	-cacheArchive ${CONF_PATH}/wdbdtools.tar.gz#wdbdtools
	
