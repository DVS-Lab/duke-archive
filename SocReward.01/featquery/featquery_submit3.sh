#!/bin/bash

#echo "sleeping for 2hours..."
#sleep 2h

#for go in 1 2 3; do

for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do

#for SUBJ in 32953; do
#SUBJ=33744

	for LIST in "Model9_faces_6mm_ST 9" "Model9_money_6mm_ST 13"; do

	set -- $LIST
	MODEL=$1
	NCOPES=$2

	
		for COPES in `seq $NCOPES`; do
	
		
		qsub -v EXPERIMENT=SocReward.01 featquery_short3.sh ${SUBJ} ${MODEL} ${COPES}
	
			qstat > testfile2
			NUM=`grep -c "qw" testfile2`
			echo "$NUM jobs in queue"
		
			while [ $NUM -gt 10 ]; do 
				sleep 16
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
			done
		#exit
	
		done

	done
	#sleep 2
done

done

rm testfile2

