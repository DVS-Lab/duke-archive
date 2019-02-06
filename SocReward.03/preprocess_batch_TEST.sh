#!/bin/bash

if [ $# -eq 0 ]; then
	echo -e "\nUSAGE: \npreprocess_batch.sh <SUBJECT_FULL> <SUBJECT> <BXH2ANALYZE> <PRESTATS> <MELODIC> "
	echo -e "\n  SUBJECT_FULL=20080818_34738\n  SUBJECT=34738\n  BXH2ANALYZE=yes/no (1/0)\n  PRESTATS=yes/no (1/0)\n  MELODIC=yes/no (1/0)\n"
	exit
elif [ ! $# -eq 5 ]; then
	echo -e "ERROR: You you should have 5 inputs. Try again."
	echo -e "\nUSAGE: \npreprocess_batch.sh <SUBJECT_FULL> <SUBJECT> <BXH2ANALYZE> <PRESTATS> <MELODIC>"
	echo -e "\n  SUBJECT_FULL=20080818_34738\n  SUBJECT=34738\n  BXH2ANALYZE=yes/no (1/0)\n  PRESTATS=yes/no (1/0)\n  MELODIC=yes/no (1/0)\n"
	exit
else
	echo -e "\nPreprocessing subject $1...\n" 
fi

#34712
SUBJ_FULL=$1
SUBJ=$2
BXH2ANALYZE=$3
PRESTATS=$4
MELODIC=$5

set -- $BXH2ANALYZE
NUMRUNS=$1
PASSIVE=$2
PASSIVE_CUED=$3
ACTIVE=$4
REST=$5
ANAT_SERIES=$6


qsub -v EXPERIMENT=SocReward.03 bxh2analyze_orient2.sh $SUBJECT_FULL $SUBJ $NUMRUNS $PASSIVE $PASSIVE_CUED $ACTIVE $REST $ANAT_SERIES
qstat > waiting
NUM=`grep -c "qw" waiting`
while [ $NUM -eq 1 ]; do 
	sleep 5
	qstat > waiting
	NUM=`grep -c "qw" waiting`
done

for go in 1 2; do
	for SMOOTH in 6 0; do
		for RUN in 1 2 3; do
			qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} Passive
		done
		for RUN in 1 2; do
			qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} PassiveCued
		done
		for RUN in 1 2; do
			qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} Active
		done
		for RUN in `seq $REST`; do
			qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} Resting
		done
		qstat > waiting
		NUM=`grep -c "qw" waiting`
		while [ $NUM -gt 5 ]; do 
			sleep 5
			qstat > waiting
			NUM=`grep -c "qw" waiting`
		done
	done
	sleep 5m
done
rm -f waiting

qstat > waiting
NUM=`grep -c "qw" waiting`
while [ $NUM -eq 1 ]; do 
	sleep 5
	qstat > waiting
	NUM=`grep -c "qw" waiting`
done

for go in 1 2; do
	for SMOOTH in 6 0; do
		for RUN in 1 2 3; do
			qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} Passive
		done
		for RUN in 1 2; do
			qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} PassiveCued
		done
		for RUN in 1 2; do
			qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} Active
		done
		for RUN in `seq $REST`; do
			qsub -v EXPERIMENT=SocReward.03 melodic_1run.sh ${SUBJ} ${RUN} ${SMOOTH} ${go} Resting
		done
		qstat > waiting
		NUM=`grep -c "qw" waiting`
		while [ $NUM -gt 5 ]; do 
			sleep 5
			qstat > waiting
			NUM=`grep -c "qw" waiting`
		done
	done
	sleep 5m
done
rm -f waiting

