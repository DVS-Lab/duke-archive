#!/bin/sh

for go in 1 2; do

	for SMOOTH in "6.0" "0"; do

		for MODEL in "face" "money"; do

			for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do
		
				for RUN in 2 3 4 5 6; do
				
					qsub -v EXPERIMENT=SocReward.01 reward_model_6_NoMotor.sh ${SUBJ} ${RUN} ${MODEL} ${SMOOTH}
					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
					echo "$NUM jobs in queue"
		
					while [ $NUM -gt 5 ]; do 
						sleep 5
						qstat > testfile2
						NUM=`grep -c "qw" testfile2`
					done
					
				done
		
			done
		
		done

	done

done


		
rm testfile2

