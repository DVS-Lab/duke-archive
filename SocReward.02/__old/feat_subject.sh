#!/bin/sh

for SUBJ in 33754; do

	for RUN in 2 3 4 5 6; do
	qsub -v EXPERIMENT=SocReward.01 feat_1run.sh ${SUBJ} ${RUN}
		
	if [ $RUN -eq 6 ]
	then
		
	QSTAT1=`qstat`
	
	while [ -n "$QSTAT1" ]; do
	sleep 100
	QSTAT1=`qstat`
	echo "still processing...   [`date`]"
	done
	fi
	
	done

done



