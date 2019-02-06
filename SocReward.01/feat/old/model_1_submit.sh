#!/bin/sh

for PREPROCESSOPTION in "noST_50s" "ST_50s" "normal" "no_preprocess_nofilter" "normal_50s" "MC_only"; do
	
	for PROCESSTYPE in "8disdaqs_only" "original" "rescaled_8disdaqs" "rescaled_only"; do

		for SUBJ in 33757 33771; do

			for RUN in 2 3 4 5 6; do
			
			qsub -v EXPERIMENT=SocReward.01 reward_model_1.sh ${SUBJ} ${RUN} ${PROCESSTYPE} ${PREPROCESSOPTION}
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
				echo "$NUM jobs in queue"

				while [ $NUM -gt 10 ]; do 
					sleep 10
					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
				done
				
			done
			sleep 20
		done
		
	done
		
done


		
rm testfile2

