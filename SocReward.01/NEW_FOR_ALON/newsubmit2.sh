#!/bin/sh

for go in 2; do
		
	for SMOOTH in 8; do
		for PERM in 1 2 3; do
			for SPACE in "native"; do
				for SUBJ in 47481 47489 47502 47512 47524 47545 47546 47553 47556 47557 47559 47583 47586 47591 47601; do

					if [ $SUBJ -eq 47512 ]; then
						continue
					fi
		
					for RUN in 1 2 3 4 5 6; do
		
						#qsub -v EXPERIMENT=Finance.01 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go}
						qsub -v EXPERIMENT=Finance.01 fishing.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} ${PERM} $SPACE
						#qsub -v EXPERIMENT=Finance.01 level2.sh ${SUBJ} ${SMOOTH} ${go}
						#qsub -v EXPERIMENT=Finance.01 extract_ROIs.sh ${SUBJ} ${RUN} ${SMOOTH} ${go}
		
						qstat > waiting
						NUM=`grep -c "qw" waiting`
						while [ $NUM -gt 8 ]; do 
							sleep 2
							qstat > waiting
							NUM=`grep -c "qw" waiting`
						done
		
					done
				done
			done
		done
	done
sleep 20m

done

rm -f waiting

