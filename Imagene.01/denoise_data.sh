#!/bin/bash

# This script takes a single input (the subject number). 
# You can modify it to loop through all subjects within this script or you can create 
# another script to submit denoise_data.sh for each subject.
#
# created by
# David V. Smith (david.v.smith@duke.edu)
# version date: 10/19/09

EXPERIMENT=/home/smith/experiments/Imagene.01

SUBJ=$1 

#this experiment had four distinct tasks. Most applications won't need a loop like this
for TASK in "Framing" "MID" "Gambling" "Resting"; do

	if [ $TASK == "Resting" ]; then
		RUN=1 #there was only one resting-state scan
	else
		RUN=3 #everything else had 3 runs
	fi

	DATADIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}/${TASK}/MELODIC
	for RUN in `seq $RUN`; do
		RUNDIR=${DATADIR}/Smooth_6mm/run${RUN}.ica
		cd ${DATADIR}/Smooth_6mm/bad
		BAD=`cat run${RUN}.txt`
		cd $RUNDIR

		if [ -e denoised_data.nii.gz ]; then
			rm -f denoised_data.nii.gz #delete older versions of denoised data if they're present
		fi

		#it is possible that some runs will not have any bad components, so this statement helps account for that
		if [ -n "$BAD" ]; then #making sure the run${RUN}.txt file isn't empty
			REGFILTCMD="fsl_regfilt -i filtered_func_data -o denoised_data -d filtered_func_data.ica/melodic_mix -f $BAD"
			eval $REGFILTCMD #this will output your denoised data (denoised_data.nii.gz)
			echo $REGFILTCMD
		else
			cp filtered_func_data.nii.gz denoised_data.nii.gz 
			echo "no bad components for ${SUBJ} ${RUN}. renaming input file to match others..."
		fi

	done
done

