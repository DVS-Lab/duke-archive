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
RUN=$5
SMOOTH=$2
GO=1
FNIRT=$3
SETORIGIN=$4
#qsub -v EXPERIMENT=HighRes.01 GT_extractTS.sh $SUBJ $S $F $SO $R

MAINDIR=${EXPERIMENT}/Analysis

if [ $SETORIGIN -eq 1 ]; then
	ANATH=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat
	ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain
	DATA=$MAINDIR/NIFTI/${SUBJ}/fMRIphysio${RUN}new${SUBJ}.nii.gz
	if [ $FNIRT -eq 1 ]; then
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm
		mkdir -p $MAINOUTPUT
		OUTPUT=${MAINOUTPUT}/run${RUN}
	else
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT/Smooth_${SMOOTH}mm
		mkdir -p $MAINOUTPUT
		OUTPUT=${MAINOUTPUT}/run${RUN}
	fi
else
	ANATH=${MAINDIR}/NIFTI2/$SUBJ/${SUBJ}_anat
	ANAT=${MAINDIR}/NIFTI2/$SUBJ/${SUBJ}_anat_brain
	DATA=$MAINDIR/NIFTI2/${SUBJ}/fMRIphysio${RUN}new${SUBJ}.nii.gz
	if [ $FNIRT -eq 1 ]; then
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT_noSO/Smooth_${SMOOTH}mm
		mkdir -p $MAINOUTPUT
		OUTPUT=${MAINOUTPUT}/run${RUN}
	else
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT_noSO/Smooth_${SMOOTH}mm
		mkdir -p $MAINOUTPUT
		OUTPUT=${MAINOUTPUT}/run${RUN}
	fi
fi

STANDARD=${MAINDIR}/FSL/MNI152_T1_1mm_brain
STANDARDH=${MAINDIR}/FSL/MNI152_T1_1mm

F
ROIDIR=${MAINDIR}/FSL/ROIs
TSMAINOUTPUT=${MAINDIR}/FSL/forJAC_similarity/$SUBJ
mkdir -p $TSMAINOUTPUT

FDATA=${OUTPUT}.feat/filtered_func_data.nii.gz
for ROI in "PPA" "FFA"; do
	LOCAL=${TSMAINOUTPUT}/ts_${ROI}_run${RUN}.txt
	FLIRTINPUT=${ROIDIR}/${ROI}.nii.gz
	REF=${OUTPUT}.feat/reg/example_func.nii.gz
	MATRIX=${OUTPUT}.feat/reg/standard2example_func.mat
	FLIRTOUTPUT=${OUTPUT}.feat/reg/${ROI}2example_func.nii.gz
	
	flirt -in ${FLIRTINPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${FLIRTOUTPUT} -interp sinc -sincwindow hanning -usesqform
	fslmaths ${FLIRTOUTPUT} -thr 0.2 -bin ${FLIRTOUTPUT}
	fslmeants -i ${FDATA} -o ${LOCAL} -m ${FLIRTOUTPUT}
done






OUTDIR=${MAINOUTPUT}/TS/Logs
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
