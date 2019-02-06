#!/bin/bash

for GO in 1 2; do
	for LIST in "face_d 1" "face_mean 2" "face_linear 3" "money_d 4" "money_mean 5" "money_linear 6" "face_d-money_d 7" "money_d-face_d 8" "face_mean-money_mean 9" "money_mean-face_mean 10" "face_linear-money_linear 11" "money_linear-face_linear 12"; do

		set -- $LIST 
		CON_NAME=$1
		COPENUM=$2
			
		qsub -v EXPERIMENT=SocReward.01 L3_1cope_linear.sh ${CON_NAME} ${COPENUM} ${GO}

		qstat > waiting.txt
		NUM=`grep -c "qw" waiting.txt`
		while [ $NUM -gt 5 ]; do 
			sleep 10
			qstat > waiting.txt
			NUM=`grep -c "qw" waiting.txt`
		done
	done
sleep 15m
done
rm waiting.txt


