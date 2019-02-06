#!/bin/sh

for go in 1 2; do
	
	for SUBJ in 47725 47729 47731 47734 47735 47737 47748 47752 47851 47863 47878 47885 47917 47921 47945 47977 48012; do
	
	# 47731 first run of framing is 134 instead of 180 time points
	# 47945 missing 3rd run of MID 
	
		for SMOOTH in 6 0; do
	
			if [ $SUBJ -eq 47945 ]; then
				for RUN in 1 2; do
					qsub -v EXPERIMENT=Imagene.01 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "MID"
				done
			else
				for RUN in 1 2 3; do
					qsub -v EXPERIMENT=Imagene.01 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "MID"
				done
			fi
	


			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 1 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done


			for RUN in 1 2 3; do
				qsub -v EXPERIMENT=Imagene.01 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Framing"
			done
	



			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 1 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done


			for RUN in 1 2 3; do
				qsub -v EXPERIMENT=Imagene.01 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Gambling"
			done
	
			qsub -v EXPERIMENT=Imagene.01 prestats_1run.sh ${SUBJ} 1 ${SMOOTH} ${go} "Resting"
	
	
			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 1 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done
			
		done
			#echo "sleeping for 5 minutes at `date`"
		#sleep 5m 
	done
		
	
	for SUBJ in 47725 47729 47731 47734 47735 47737 47748 47752 47851 47863 47878 47885 47917 47921 47945 47977 48012; do
		
		for SMOOTH in 6 0; do
	
			if [ $SUBJ -eq 47945 ]; then
				for RUN in 1 2; do
					qsub -v EXPERIMENT=Imagene.01 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "MID"
				done
			else
				for RUN in 1 2 3; do
					qsub -v EXPERIMENT=Imagene.01 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "MID"
				done
			fi
	


			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 1 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done


			for RUN in 1 2 3; do
				qsub -v EXPERIMENT=Imagene.01 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Framing"
			done
	
			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 1 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done

			for RUN in 1 2 3; do
				qsub -v EXPERIMENT=Imagene.01 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Gambling"
			done
	
			qsub -v EXPERIMENT=Imagene.01 melodic_1run.sh ${SUBJ} 1 ${SMOOTH} ${go} "Resting"
	
	
			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 1 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done
			
		done
	
	done

done