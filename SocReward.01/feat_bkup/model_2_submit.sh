#!/bin/sh


for RUN_JOBS in 1 2; do 

	for SMOOTH in 6 8; do
  
		for AUTOVERSION in "0.7.1"; do
		
			for OPTION in "crap"; do

				for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do
	
					for RUN in 2 3 4 5 6; do
					
					if [ $SUBJ -eq 33732 ] && [ $RUN -eq 4 ]; then
						continue
					fi
	
# 						qstat > testfile2
# 						NUM=`grep -c "qw" testfile2`
# 						echo "$NUM jobs in queue"
# 		
# 						while [ $NUM -gt 12 ]; do 
# 							sleep 10
# 							qstat > testfile2
# 							NUM=`grep -c "qw" testfile2`
# 						done
						qsub -v EXPERIMENT=SocReward.01 reward_model_1.sh ${SUBJ} ${RUN} ${SMOOTH} ${AUTOVERSION} ${OPTION}

					done
					
				done
				
			done
			
		done
		
	done
	
done
		
rm -f testfile2

