#!/bin/bash

awk -F'	' '{
	split($2, arr, "/");
	print $0 > "./data/assite1/"arr[3];
}' output_sd1 
