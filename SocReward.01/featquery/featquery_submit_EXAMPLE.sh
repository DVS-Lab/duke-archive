#!/bin/bash

#echo "sleeping for 2hours..."
#sleep 2h

for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do

	for LIST in "Model8_faces_NoMotor_6mm_ST_TD 10" "Model8_money_NoMotor_6mm_ST_TD 10" "Model8_faces_6mm_ST_TD 10" "Model8_money_6mm_ST_TD 10"; do

		set -- $LIST
		MODEL=$1
		NCOPES=$2
	
		for COPES in `seq $NCOPES`; do
		
			qsub -v EXPERIMENT=SocReward.01 featquery_short3.sh ${SUBJ} ${MODEL} ${COPES}
	
			qstat > testfile2
			NUM=`grep -c "qw" testfile2`
			while [ $NUM -gt 20 ]; do 
				sleep 10
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
			done
	
		done
	done
done
