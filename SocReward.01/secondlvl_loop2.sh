#!/bin/sh

for GO in 1 2; do
	for OPTION in "Face" "Money"; do
		for SUBJ in 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do
			
			qsub -v EXPERIMENT=SocReward.01 secondlvl_feat2.sh ${SUBJ} ${OPTION} ${GO}
			qstat > testfile2
			NUM=`grep -c "qw" testfile2`
			while [ $NUM -gt 2 ]; do 
				sleep 5
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
			done
		done
	done
done

rm -f testfile2


