#!/bin/sh

COUNTER=0
LOOP=0
for go in 1 2; do
	for SMOOTH in 8; do

		for TYPE in "LF_NoHoles" "LF_w_Holes" "NORMAL"; do

		NCOPES=1
				for SUBJ in RASD18 RASD19 RASD20 RASD21 RASD22 RASD23 RASD24 RASD25 RASD26 RASD29 RASD30 RASD31 RASD32 RASD33 RASD34; do
		
					qsub -v EXPERIMENT=Finance.01 second_level.sh ${SUBJ} ${SMOOTH} ${go} ${TYPE} ${NCOPES}
					qstat > testfile2
					NUM=`grep -c "qw" testfile2`
					while [ $NUM -gt 8 ]; do 
						sleep 2
						qstat > testfile2
						NUM=`grep -c "qw" testfile2`
					done
				done
	
			
		done
	done
done

rm -f testfile2

