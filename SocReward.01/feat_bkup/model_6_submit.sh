#!/bin/sh


#for RUN_JOBS in 1 2; do 

	for SMOOTH in 6; do
  
		for AUTOVERSION in "0.7.1"; do
		
			for OPTION in "crap_removed"; do

				for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do
				#for SUBJ in 33746; do

					for RUN in 2 3 4 5 6; do
					
					if [ $SUBJ -eq 33732 ] && [ $RUN -eq 4 ]; then
						continue
					fi
	
					qsub -v EXPERIMENT=SocReward.01 reward_model_6.sh ${SUBJ} ${RUN} ${SMOOTH} ${AUTOVERSION} ${OPTION}
					qsub -v EXPERIMENT=SocReward.01 reward_model_6_NoMotor.sh ${SUBJ} ${RUN} ${SMOOTH} ${AUTOVERSION} ${OPTION}
						qstat > testfile2
						NUM=`grep -c "qw" testfile2`
						echo "$NUM jobs in queue"
		
						while [ $NUM -gt 30 ]; do 
							sleep 10
							qstat > testfile2
							NUM=`grep -c "qw" testfile2`
						done
						
					done
					sleep 40
				done
				
			done
			
		done
		
	done
	
#done
		
rm testfile2

