#!/bin/bash



for LIST in "32641 5"; do

set -- $LIST

SUBJ=$1
RUNS=$2

MAINDIR=/export/data1/Projects/Flanker/Flanker_FMRI_DATA+ANALYSES/Analysis/MELODIC
SUBJDIR=${MAINDIR}/${SUBJ}_melodic


	for RUN in `seq $RUNS`; do

	RUNDIR=${SUBJDIR}/${SUBJ}_run${RUN}.ica
	
	cd $SUBJDIR
	CRAP=`cat run${RUN}.txt`
	
	cd $RUNDIR
	REGFILTCMD="fsl_regfilt -i filtered_func_data -o denoised_data -d filtered_func_data.ica/melodic_mix -f $CRAP"
	eval $REGFILTCMD
	echo $REGFILTCMD
	done

done

