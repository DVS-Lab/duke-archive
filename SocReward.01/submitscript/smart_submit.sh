#!/bin/bash

COUNTER=0
LOOP=0

for SUBJ in 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33135 33402 33456 33642 33669 33732 33746 33754 33757 33771 33784 33467 33744 32904 32918; do
	for RUN in 2 3 4 5 6; do

		qstat > qstatreport
		NUM=`grep -c "qw" qstatreport`
		echo "$NUM jobs in queue"
		while [ $NUM -gt 10 ]; do 
			sleep 10
			qstat > qstatreport
			NUM=`grep -c "qw" qstatreport`
		done
		qsub -v EXPERIMENT=SocReward.01 test_short.sh ${SUBJ} ${RUN} ${JOBLENGTH}

	done
done
rm -f qstatreport



