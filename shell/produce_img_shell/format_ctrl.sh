#!/bin/bash

echo "source format_data.sh ..."
source ./shell/produce_img_shell/format_data.sh

if [ $? -ne 0 ]
then
	echo "source failed."
	exit 1
fi

format_data "dingxiang"
#format_data "mine"

