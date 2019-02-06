#!/bin/sh

# This is a BIAC template script for jobs on the cluster
# You have to provide the Experiment on command line  
# when you submit the job the cluster.
#
# >  qsub -v EXPERIMENT=Dummy.01  script.sh args
#
# There are 2 USER sections 
#  1. USER DIRECTIVE: If you want mail notifications when
#     your job is completed or fails you need to set the 
#     correct email address.
#		   
#  2. USER SCRIPT: Add the user script in this section.
#     Within this section you can access your experiment 
#     folder using $EXPERIMENT. All paths are relative to this variable
#     eg: $EXPERIMENT/Data $EXPERIMENT/Analysis	
#     By default all terminal output is routed to the " Analysis "
#     folder under the Experiment directory i.e. $EXPERIMENT/Analysis
#     To change this path, set the OUTDIR variable in this section
#     to another location under your experiment folder
#     eg: OUTDIR=$EXPERIMENT/Analysis/GridOut 	
#     By default on successful completion the job will return 0
#     If you need to set another return code, set the RETURNCODE
#     variable in this section. To avoid conflict with system return 
#     codes, set a RETURNCODE higher than 100.
#     eg: RETURNCODE=110
#     Arguments to the USER SCRIPT are accessible in the usual fashion
#     eg:  $1 $2 $3
# The remaining sections are setup related and don't require
# modifications for most scripts. They are critical for access
# to your data  	 

# --- BEGIN GLOBAL DIRECTIVE -- 
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
# -- END GLOBAL DIRECTIVE -- 

# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access 
EXPERIMENT=${EXPERIMENT:?"Experiment not provided"}

source /etc/biac_sge.sh

EXPERIMENT=`biacmount $EXPERIMENT`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}

if [ $EXPERIMENT = "ERROR" ]
then
	exit 32
else 
#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----" 
# -- END PRE-USER --
# **********************************************************

# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

SUBJ=$1
RUN=$3
SMOOTH=0
FNIRT=$2



MAINDIR=${EXPERIMENT}/Analysis

ANATH=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat
ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain
if [ $FNIRT -eq 1 ]; then
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/run${RUN}
else
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT/Smooth_${SMOOTH}mm
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/run${RUN}
fi
#Analysis/FSL/1002/PreStats_FNIRT/Smooth_0mm/run1.feat/prestats_phase2_2resample.ica/std_unconfounded_data.nii.gz

# 1005: 4,5*
# 1006: 4*
# 1008: 5*
# 1009: 2,3,4,5*
# 1014: 4,5*
# 1015: 1,4,5*
# 1017: 2*
# 1020: 5*
# 1023: 2,3,4,5*
# if [ $SUBJ -eq 1005 -o $SUBJ -eq 1014 ] && [ $RUN -eq 4 -o $RUN -eq 5 ]; then
# 	SKIP=1
# 	echo "skipping"
# elif [ $SUBJ -eq 1023 -o $SUBJ -eq 1009 ] && [ $RUN -eq 2 -o $RUN -eq 3 -o $RUN -eq 4 -o $RUN -eq 5 ]; then
# 	SKIP=1
# 	echo "skipping"
# elif [ $SUBJ -eq 1020 -o $SUBJ -eq 1008 ] && [ $RUN -eq 5 ]; then
# 	SKIP=1
# 	echo "skipping"
# elif [ $SUBJ -eq 1017 ] && [ $RUN -eq 2 ]; then
# 	SKIP=1
# 	echo "skipping"
# elif [ $SUBJ -eq 1006 ] && [ $RUN -eq 4 ]; then
# 	SKIP=1
# 	echo "skipping"
# elif [ $SUBJ -eq 1015 ] && [ $RUN -eq 1 -o $RUN -eq 4 -o $RUN -eq 5 ]; then
# 	SKIP=1
# 	echo "skipping"
# else
# 	cd ${OUTPUT}.feat/prestats_phase2_2resample.ica
# 	fslmaths std_unconfounded_data.nii.gz -Tmean -bin std_uc_mask
# fi

if [ $SUBJ -eq 1020 -o $SUBJ -eq 1023 ] && [ $RUN -eq 5 ]; then
	SKIP=1
	echo "skipping"
else
	cd ${OUTPUT}.feat/prestats_phase2_2resample.ica
	fslmaths std_unconfounded_data.nii.gz -Tmean -bin std_uc_mask
fi

OUTDIR=${MAINOUTPUT}/Logs
mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
