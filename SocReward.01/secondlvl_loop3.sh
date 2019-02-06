#!/bin/sh

#echo "sleeping for 4 hours"
#sleep 4h

for NEG in "yes" "no"; do

	for SCALEDONLY in "yes" "no"; do 
	
		for OPTION in "faces" "money"; do
	
			for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do
				
				qsub -v EXPERIMENT=SocReward.01 secondlvl_feat3.sh ${SUBJ} ${OPTION} ${NEG} ${SCALEDONLY}
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


