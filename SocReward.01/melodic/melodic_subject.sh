#!/bin/sh

for GO_NOW in 1 2; do
COUNTER2=0
COUNTER=0


for SUBJ in 33456 32953 32958 32976 32984 33035 33045 33064 33082 33135 33288 33302 33402 33744 33467 33642 33669 33732 33746 33754 33757 33771 33784; do

	for RUN in 2 3 4 5 6; do
	qsub -v EXPERIMENT=SocReward.01 ica_nobet_1run.sh ${SUBJ} ${RUN}
	let "COUNTER=$COUNTER+1"
	let "COUNTER2=$COUNTER2+1"
	echo $COUNTER2
	if [ $COUNTER -eq 10 ]; then
		if [ $GO_NOW -eq 2 ]; then
		echo "sleeping for 5 minutes because we're on the second iteration"
		sleep 300
		COUNTER=0
		else	
		echo "sleeping for 20 minutes at `date`"
		sleep 1200
		COUNTER=0
		fi
	fi
	
	done

done



done
