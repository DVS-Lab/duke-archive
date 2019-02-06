#!/bin/sh

for go in 1 2; do
	
	for SUBJ in 47725 47729 47731 47734 47735 47737 47748 47752 47851 47863 47878 47885 47917 47921 47945 47977 48012; do
	
	# 47731 first run of framing is 134 instead of 180 time points
	# 47945 missing 3rd run of MID 
	
		for SMOOTH in 8 0; do
	
			
			qsub -v EXPERIMENT=Imagene.01 prestats_1run2.sh ${SUBJ} 1 ${SMOOTH} ${go} "Resting"
	
	
			
		done
			#echo "sleeping for 5 minutes at `date`"
		#sleep 5m 
	done
	echo "sleeping for 30 minutes at `date`"
	sleep 30m
done