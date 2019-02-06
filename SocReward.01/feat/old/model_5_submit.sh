#!/bin/sh


for PREPROCESSOPTION in "noST_25s" "ST_25s" "normal_25s"; do
	
	for PROCESSTYPE in "8disdaqs_only" "rescaled_8disdaqs"; do

		for SUBJ in 33757 33771; do

			for RUN in 2 3 4 5 6; do
			
			qsub -v EXPERIMENT=SocReward.01 reward_model_5_test.sh ${SUBJ} ${RUN} ${PROCESSTYPE} ${PREPROCESSOPTION}
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
				echo "$NUM jobs in queue"

				while [ $NUM -gt 20 ]; do 
					sleep 10
					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
				done
				
			done
			sleep 1
		done
		
	done
		
done


		
rm testfile2

