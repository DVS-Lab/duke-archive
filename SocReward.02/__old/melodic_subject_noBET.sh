#!/bin/sh


#SUBJ=$1

for SUBJ in 32953 32958 32976 32984 33035 33045 33064 33082 33135 33288 33302 33402 33744 33467 33642 33669 33732 33746 33754 33757 33771 33784 33456; do

#32953 32958 32976 32984 33035 33045 33064 33082 33135 33288 33302 33402 33744 33467 33642 33669 33732 33746 33754 33757 33771 33784; do

	for RUN in 2 3 4 5 6; do
	qsub -v EXPERIMENT=SocReward.01 melodic_1run_noBET.sh ${SUBJ} ${RUN}
		
	#if [ $RUN -eq 6 ]
	#then
		
	#QSTAT1=`qstat`
	
	#while [ -n "$QSTAT1" ]; do
	#sleep 100
	#QSTAT1=`qstat`
	#echo "still processing at `date`"
	#done
	#fi
	
	done

done



