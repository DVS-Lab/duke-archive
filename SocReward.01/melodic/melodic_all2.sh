#!/bin/sh

COUNTER=0
LOOP=0

for keepgoing in 1 2; do 

for SUBJ in 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33135 33402 33456 33642 33732 33746 33754 33757 33771 33784 33467 33744 32918; do
#for SUBJ in 33135 33082; do
	for RUN in 2 3 4 5 6; do
	qsub -v EXPERIMENT=SocReward.01 melodic_1run_new2.sh ${SUBJ} ${RUN}

		qstat > testfile4
		NUM=`grep -c "qw" testfile4`
		#echo "$NUM jobs in queue. will maintain 10 in the queue"
		while [ $NUM -gt 1 ]; do 
		sleep 10
		qstat > testfile4
		NUM=`grep -c "qw" testfile4`
		done
	
	done
  #sleep 2
done

done
rm -f testfile4





