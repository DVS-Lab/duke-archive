#!/bin/sh

#for SUBJ in 33467 33744; do
COUNTER=0
LOOP=0
for SUBJ in 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33135 33402 33456 33642 33669 33732 33746 33754 33757 33771 33784 33467 33744; do
#for SUBJ in 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33135 33402 33456 33642 33669 33732 33746 33754 33757 33771 33784 33467 33744; do	
	for RUN in 2 3 4 5 6; do
	qsub -v EXPERIMENT=SocReward.01 full_test_1run.sh ${SUBJ} ${RUN}
	let "COUNTER=$COUNTER+1"
	echo $COUNTER
	if [ $COUNTER -eq 15 ]; then		
	QSTAT1=`qstat`
		let "LOOP=$LOOP+1"
		#while [ -n "$QSTAT1" ]; do
		#sleep 120
		#QSTAT1=`qstat`
		#echo "still processing at `date`"
		#done
		echo "sleeping for 20 minutes at `date`. loop $LOOP"
		sleep 1200
		COUNTER=0
		
	fi
	
	done

done



