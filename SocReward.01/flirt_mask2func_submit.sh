#!/bin/bash
#echo "sleeping for 2hours..."
#sleep 2h

for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do

# "Model1_6mm_ST_v0.7.1_new3 10"
# "Model1_8mm_ST_v0.7.1_new3 10"
# "FEAT_noTD_6mm_ST_v0.6.5 22" 
# "FEAT_noTD_6mm_ST_v0.7.1 22" 

	for RUNS in 2 3 4 5 6; do
	
	if [ "$SUBJ" -eq 33732 ] && [ "$RUNS" -eq 4 ]; then
		continue
	fi


	qsub -v EXPERIMENT=SocReward.01 flirt_mask2func.sh ${SUBJ} ${RUNS}

		qstat > testfile2
		NUM=`grep -c "qw" testfile2`
		echo "$NUM jobs in queue"
	
		while [ $NUM -gt 15 ]; do 
			sleep 10
			qstat > testfile2
			NUM=`grep -c "qw" testfile2`
		done
	#exit

	done
	sleep 2
done

