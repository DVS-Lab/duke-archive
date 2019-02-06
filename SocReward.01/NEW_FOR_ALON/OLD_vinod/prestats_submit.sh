#!/bin/sh

COUNTER=0
LOOP=0
for go in 1; do

	for SESSION in "RW"; do
		
		for SMOOTH in 0 8; do
		
			for SUBJ in RASD18 RASD19 RASD20 RASD21 RASD22 RASD23 RASD24 RASD25 RASD26 RASD29 RASD30 RASD31 RASD32 RASD33 RASD34; do

				for RUN in 1 2 3 4 5 6; do

					#qsub -v EXPERIMENT=Finance.01 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${SESSION} ${go}
					qsub -v EXPERIMENT=Finance.01 maskfix+flirt_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${SESSION} ${go}

					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
					echo "$NUM jobs in queue"
					while [ $NUM -gt 1 ]; do 
					sleep 5
					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
					done
				
				done
				
			done
	
		done
	
	done

done

rm -f testfile2

