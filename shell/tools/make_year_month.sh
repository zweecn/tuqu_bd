#!/bin/bash


for ((y=1990; y<=2020; y++))
do
	echo $y"��"
	for ((m=1; m<=12; m++))
	do
		echo $y"��"$m"��" 
		echo $m"��"
		echo $y"-"$m
		echo $y"."$m
		for ((d=1; d<=31; d++))
		do
			if [ $m -lt 10 ] && [ $d -lt 10 ] ; then
				echo $y"-0"$m"-0"$d
				echo $y".0"$m".0"$d
			fi
			if [ $m -lt 10 ] && [ $d -ge 10 ] ; then
				echo $y"-0"$m"-"$d
				echo $y".0"$m"."$d
			fi
			if [ $m -ge 10 ] && [ $d -lt 10 ] ; then
				echo $y"-"$m"-0"$d
				echo $y"."$m".0"$d
			fi

			echo $y"-"$m"-"$d
			echo $y"."$m"."$d
			echo $y"��"$m"��"$d"��"
		done
	done
done 
