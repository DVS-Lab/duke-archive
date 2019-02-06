#!/bin/sh

for OPTION in "faces" "money"; do
	

	for MODEL in "Model11_neg_scaled_${OPTION}_NoMotor_6mm_ST" "Model11_scaled_${OPTION}_NoMotor_6mm_ST" "Model10_neg_scaled_${OPTION}_NoMotor_6mm_ST" "Model10_scaled_${OPTION}_NoMotor_6mm_ST"; do
	
	
		for LIST in "scaled 1" "constant 2"; do
	
			set -- $LIST 
			CON_NAME=$1
			COPENUM=$2
				
			qsub -v EXPERIMENT=SocReward.01 third_level_new_1cope2.sh ${CON_NAME} ${COPENUM} ${MODEL} ${OPTION}
					
			qstat > testfile2
			NUM=`grep -c "qw" testfile2`
			echo "$NUM jobs in queue"
		
			while [ $NUM -gt 5 ]; do 
				sleep 10
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
			done
		
		done
	done
	
	#scaled only
	for MODEL in "Model11_neg_scaledonly_${OPTION}_NoMotor_6mm_ST" "Model11_scaledonly_${OPTION}_NoMotor_6mm_ST" "Model10_neg_scaledonly_${OPTION}_NoMotor_6mm_ST" "Model10_scaledonly_${OPTION}_NoMotor_6mm_ST"; do
	
		for LIST in "scaled 1"; do
	
			set -- $LIST 
			CON_NAME=$1
			COPENUM=$2
				
			qsub -v EXPERIMENT=SocReward.01 third_level_new_1cope2.sh ${CON_NAME} ${COPENUM} ${MODEL} ${OPTION}
					
			qstat > testfile2
			NUM=`grep -c "qw" testfile2`
			echo "$NUM jobs in queue"
		
			while [ $NUM -gt 5 ]; do 
				sleep 10
				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
			done
	
		done
	
	done
		
done


rm testfile2


