#!/bin/sh

for GO in 1 2; do
	#for PERM in 4 1 2 3; do
		for TYPE in 3 2 0; do
			for LIST in "1star 1" "2star 2" "3star 3" "4star 4" "face 5" "4star-1star 6" "1star-4star 7" "hot-not 8" "not-hot 9"; do
		
				set -- $LIST 
				CON_NAME=$1
				COPENUM=$2

				#qsub -v EXPERIMENT=SocReward.01 third_level_new_1cope.sh ${CON_NAME} ${COPENUM} ${PERM} ${GO} ${TYPE}
				#CMD="qsub -v EXPERIMENT=SocReward.01 third_level_new_1cope.sh ${CON_NAME} ${COPENUM} ${PERM} ${GO} ${TYPE}"
				#echo $CMD

				qsub -v EXPERIMENT=SocReward.01 third_level_new_1cope.sh ${CON_NAME} ${COPENUM} ${GO} ${TYPE}
				CMD="qsub -v EXPERIMENT=SocReward.01 third_level_new_1cope.sh ${CON_NAME} ${COPENUM} ${GO} ${TYPE}"
				echo $CMD


				qstat > testfile2
				NUM=`grep -c "qw" testfile2`
				while [ $NUM -gt 2 ]; do 
					sleep 2
					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
				done

			done
		done
	#done
done
		



rm testfile2


