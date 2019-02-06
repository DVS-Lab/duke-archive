#!/bin/sh

COUNTER=0
LOOP=0
#for go in 1 2; do
#echo "sleeping for 20 minutes"
#sleep 20m

	for SESSION in "RW"; do
		
		for SMOOTH in 0 8; do
		
			for SUBJ in RASD18 RASD19 RASD20 RASD21 RASD22 RASD23 RASD24 RASD25 RASD26 RASD29 RASD30 RASD31 RASD32 RASD33 RASD34; do

				for RUN in 1 2 3 4 5 6; do

					qsub -v EXPERIMENT=Finance.01 maskfix+flirt_1run2.sh ${SUBJ} ${RUN} ${SMOOTH} ${SESSION}
					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
					while [ $NUM -gt 10 ]; do 
					sleep 5
					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
					done
				
				done
				
			done
	
		done
	
	done

#done

rm -f testfile2

