#!/bin/sh

for go in 1 2; do
	for SMOOTH in 6 8 0; do
		for SUBJ in "34712 0" "34742 0" "34756 0"; do
		
			set -- $SUBJ
			SUBJ=$1
			REST=$2

			for RUN in 1 2 3; do
				qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} Passive
			done

			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 10 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done

			for RUN in 1 2; do
				qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} PassiveCued
			done

			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 10 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done

			for RUN in 1 2; do
				qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} Active
			done

			for RUN in `seq $REST`; do
				qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} Resting
			done

			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 10 ]; do 
				sleep 5
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done

		done
	done
	sleep 15m
done

rm -f waiting

