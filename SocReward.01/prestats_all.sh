#!/bin/sh

COUNTER=0
LOOP=0
for go in 1 2; do
 
for TEMPLATE in "prestats_noSmooth_ST"; do
  
   #for SUBJ in 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33135 33402 33456 33642 33669 33732 33746 33754 33757 33771 33784 33467 33744 32904 32918; do
for SUBJ in 33135 33082; do
	for RUN in 2 3 4 5 6; do
	qsub -v EXPERIMENT=SocReward.01 prestats_1run.sh ${SUBJ} ${RUN} ${TEMPLATE}

		qstat > testfile2
		NUM=`grep -c "qw" testfile2`
		echo "$NUM jobs in queue"
		while [ $NUM -gt 20 ]; do 
		sleep 5
		qstat > testfile2
		NUM=`grep -c "qw" testfile2`
		done
	
	done
	
   done
done

done

rm -f testfile2
