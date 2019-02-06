#!/bin/sh

SUBJ=$1
REST=$2

for go in 1 2; do
	for SMOOTH in 6 0; do
		#for SUBJ in "34712 0" "34742 0" "34783 0" "34793 0" "34862 0" "34909 0" "34915 0" "34950 0" "39752 0" "34967 0" "34970 0" "34990 0"; do
		for SUBJ in "34952 0" "35009 0" "35025 0" "35086 0" "35267 0" "35280 0" "35283 0"; do
			set -- $SUBJ
			SUBJ=$1
			REST=$2

			for RUN in 1 2 3; do
				qsub -v EXPERIMENT=SocReward.03 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Passive"
			done

			if [ $SUBJ -eq 35086 ]; then
				for RUN in 1; do
					qsub -v EXPERIMENT=SocReward.03 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "PassiveCued"
				done
			else
				for RUN in 1 2; do
					qsub -v EXPERIMENT=SocReward.03 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "PassiveCued"
				done
			fi

			for RUN in 1 2; do
				qsub -v EXPERIMENT=SocReward.03 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Active"
			done

			for RUN in `seq $REST`; do
				qsub -v EXPERIMENT=SocReward.03 prestats_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Resting"
			done

			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 1 ]; do 
				sleep 30
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done

		done
	done
	echo "sleeping for 5 minutes at `date`"
	sleep 5m 
done			

qstat > waiting
NUM=`grep -c "prestats" waiting`
while [ $NUM -gt 0 ]; do 
	sleep 30
	echo "waiting for prestats to finish at `date`...."
	qstat > waiting
	NUM=`grep -c "prestats" waiting`
done


for go in 1 2; do
	for SMOOTH in 6 0; do
		#for SUBJ in "34712 0" "34742 0" "34783 0" "34793 0" "34862 0" "34909 0" "34915 0" "34950 0" "39752 0" "34967 0" "34970 0" "34990 0"; do
		for SUBJ in "34952 0" "35009 0" "35025 0" "35086 0" "35267 0" "35280 0" "35283 0"; do
		
			set -- $SUBJ
			SUBJ=$1
			REST=$2

			for RUN in 1 2 3; do
				qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Passive"
			done
			
			if [ $SUBJ -eq 35086 ]; then
				for RUN in 1; do
					qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "PassiveCued"
				done
			else
				for RUN in 1 2; do
					qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "PassiveCued"
				done
			fi

			for RUN in 1 2; do
				qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Active"
			done

			for RUN in `seq $REST`; do
				qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} "Resting"
			done

			qstat > waiting
			NUM=`grep -c "qw" waiting`
			while [ $NUM -gt 1 ]; do 
				sleep 30
				qstat > waiting
				NUM=`grep -c "qw" waiting`
			done

		done
	done
	echo "sleeping for 5 minutes at `date`"
	sleep 5m
done