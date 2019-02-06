#!/bin/sh

SMOOTH=6
for TD in "no"; do
	
	#for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do
	for SUBJ in 33754 33757; do

		for RUN in 2 3 4 5 6; do
		
			if [ $SUBJ -eq 33732 ] && [ $RUN -eq 4 ]; then
				continue
			fi
	
	
	
			#qsub -v EXPERIMENT=SocReward.01 reward_model_9_faces.sh ${SUBJ} ${RUN} ${SMOOTH} ${TD}
			#qsub -v EXPERIMENT=SocReward.01 reward_model_9_money.sh ${SUBJ} ${RUN} ${SMOOTH} ${TD}
			qsub -v EXPERIMENT=SocReward.01 reward_model_9_faces_NM.sh ${SUBJ} ${RUN} ${SMOOTH} ${TD}
			#qsub -v EXPERIMENT=SocReward.01 reward_model_9_money_NM.sh ${SUBJ} ${RUN} ${SMOOTH} ${TD}
	
			qstat > testfile2
			NUM=`grep -c "qw" testfile2`
			echo "$NUM jobs in queue"
	
			while [ $NUM -gt 10 ]; do 
				sleep 10
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
			done
			
		done
	
	sleep 30
	done
	
done
	
rm testfile2

