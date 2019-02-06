#!/bin/bash

#echo "sleeping for 2hours..."
#sleep 2h

for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do




	for LIST in "Model9_faces_NoMotor_6mm_ST 10" "Model9_money_NoMotor_6mm_ST 10" "Model9_faces_NoMotor_6mm_ST_TD 10" "Model9_money_NoMotor_6mm_ST_TD 10" "Model9_faces_6mm_ST 10" "Model9_money_6mm_ST 10" "Model9_faces_6mm_ST_TD 10" "Model9_money_6mm_ST_TD 10"; do

	set -- $LIST
	MODEL=$1
	NCOPES=$2

	
		for COPES in 11 12 13; do
	
		
		qsub -v EXPERIMENT=SocReward.01 featquery_short2.sh ${SUBJ} ${MODEL} ${COPES}
	
			qstat > testfile2
			NUM=`grep -c "qw" testfile2`
			echo "$NUM jobs in queue"
		
			while [ $NUM -gt 10 ]; do 
				sleep 2
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
			done
		#exit
	
		done

	done
	#sleep 2
done

rm testfile2

