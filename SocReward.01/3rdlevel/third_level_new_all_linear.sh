#!/bin/sh




for OPTION in "Face" "Money"; do
	for LIST in "scaled 1" "constant 2"; do
	
		set -- $LIST 
		CON_NAME=$1
		COPENUM=$2
	
		qsub -v EXPERIMENT=SocReward.01 third_level_new_1cope_linear.sh ${CON_NAME} ${COPENUM} ${OPTION}
		qstat > testfile2
		NUM=`grep -c "qw" testfile2`
		while [ $NUM -gt 5 ]; do 
			sleep 10
			qstat > testfile2
			NUM=`grep -c "qw" testfile2`
		done
	
	done
done
rm testfile2


