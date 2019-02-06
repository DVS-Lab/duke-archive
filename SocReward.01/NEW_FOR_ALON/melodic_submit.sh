#!/bin/sh
for go in 1 2; do
	for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33135 33402 33456 33642 33732 33746 33754 33757 33771 33784 33467 33744; do
		for RUN in 2 3 4 5 6; do

			#qsub -v EXPERIMENT=SocReward.01 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go}
			#qsub -v EXPERIMENT=SocReward.01 stats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} ${PERM}
			#qsub -v EXPERIMENT=SocReward.01 level2.sh ${SUBJ} ${SMOOTH} ${go} ${PERM}
			#qsub -v EXPERIMENT=Finance.01 extract_ROIs.sh ${SUBJ} ${RUN} ${SMOOTH} ${go}
			qsub -v EXPERIMENT=SocReward.01 melodic_1run.sh ${SUBJ} ${RUN} ${go}

			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 4 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done
		done
	done
done
rm -f waiting

