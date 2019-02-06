#!/bin/sh

for TD in "yes"; do

	for MOTOR in "no"; do 
	
		for OPTION in "money"; do
	
			#for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do
			for SUBJ in 33732 33784; do	
				qsub -v EXPERIMENT=SocReward.01 secondlvl_feat1.sh ${SUBJ} ${OPTION} ${MOTOR} ${TD}
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
				echo "$NUM jobs in queue"
	
				while [ $NUM -gt 5 ]; do 
					sleep 10
					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
				done
						
			done
					
			
		done
		
	done

done

rm -f testfile2


