#!/bin/sh

for SUBJ in 33288 33302 33402 33456 33467 33642 33669 33732 33744 33746 33754 33757 33771 33784; do

	for RUN in 2 3 4 5 6; do
	qsub -v EXPERIMENT=SocReward.01 feat_1run.sh ${SUBJ} ${RUN}
		
	done

done



