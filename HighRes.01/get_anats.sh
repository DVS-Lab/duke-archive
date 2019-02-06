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



MAINDIR=${EXPERIMENT}/Analysis/ANTS

STANDARD=${FSLDIR}/data/standard/MNI152_T1_1mm_brain


OUTPUTDIR=$MAINDIR/T1s_affine_1mm

mkdir -p $OUTPUTDIR
N=0
for SUBJ in 1002 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023; do
	let N=$N+1

	FLIRTIN=${EXPERIMENT}/Analysis/NIFTI/${SUBJ}/${SUBJ}_anat_brain
	FLIRTOUT=${OUTPUTDIR}/${SUBJ}_T1_brain
	MAT=${OUTPUTDIR}/${SUBJ}_T1_brain.mat
	flirt -ref $STANDARD -in $FLIRTIN -out $FLIRTOUT -omat $MAT -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear

	FLIRTIN=${EXPERIMENT}/Analysis/NIFTI/${SUBJ}/${SUBJ}_anat
	FLIRTOUT=${OUTPUTDIR}/${SUBJ}_T1_wholehead
	flirt -ref $STANDARD -in $FLIRTIN -out $FLIRTOUT -applyxfm -init $MAT -interp trilinear

done
cd $OUTPUTDIR
fslmerge -t T1s_4D_n${N}_brain *_brain.nii.gz
fslmerge -t T1s_4D_n${N}_wholehead *_wholehead.nii.gz
fslmaths T1s_4D_n${N}_brain -Tmean T1s_mean_n${N}_brain
fslmaths T1s_4D_n${N}_wholehead -Tmean T1s_mean_n${N}_wholehead
mkdir brain 
mv 10*_T1_brain.nii.gz brain/.
mkdir wholehead
mv 10*_T1_wholehead.nii.gz wholehead/.

OUTDIR=$MAINDIR/Logs
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
