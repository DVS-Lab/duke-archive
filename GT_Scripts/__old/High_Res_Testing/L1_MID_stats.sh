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

FSLDIR=/usr/local/fsl-4.1.4-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh



SUBJ=$1
run=$2



MAINDIR=$EXPERIMENT/Analysis/high-res_TEST/${SUBJ}

OUTPUT=$MAINDIR/MID/run$run
ANAT=$MAINDIR/${SUBJ}_anat_brain.nii.gz
DATA=$MAINDIR/MID/run0${run}.nii.gz


EVDIR=$MAINDIR/MID/run$run
let run2=$run-1
VAR01=${EVDIR}/money_low_trial_antic_${run2}.txt #really high
VAR02=${EVDIR}/money_high_trial_antic_${run2}.txt #really low
VAR03=${EVDIR}/candy_high_trial_antic_${run2}.txt
VAR04=${EVDIR}/candy_low_trial_antic_${run2}.txt
VAR05=${EVDIR}/zero_trial_antic_${run2}.txt
VAR06=${EVDIR}/money_high_outcome_yes_${run2}.txt
VAR07=${EVDIR}/money_high_outcome_no_${run2}.txt
VAR08=${EVDIR}/money_low_outcome_yes_${run2}.txt
VAR09=${EVDIR}/money_low_outcome_no_${run2}.txt
VAR10=${EVDIR}/candy_high_outcome_yes_${run2}.txt
VAR11=${EVDIR}/candy_high_outcome_no_${run2}.txt
VAR12=${EVDIR}/candy_low_outcome_yes_${run2}.txt
VAR13=${EVDIR}/candy_low_outcome_no_${run2}.txt
VAR14=${EVDIR}/zero_trial_outcome_${run2}.txt


TEMPLATEDIR=$MAINDIR/MID
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@VAR01@'$VAR01'@g' \
-e 's@VAR02@'$VAR02'@g' \
-e 's@VAR03@'$VAR03'@g' \
-e 's@VAR04@'$VAR04'@g' \
-e 's@VAR05@'$VAR05'@g' \
-e 's@VAR06@'$VAR06'@g' \
-e 's@VAR07@'$VAR07'@g' \
-e 's@VAR08@'$VAR08'@g' \
-e 's@VAR09@'$VAR09'@g' \
-e 's@VAR10@'$VAR10'@g' \
-e 's@VAR11@'$VAR11'@g' \
-e 's@VAR12@'$VAR12'@g' \
-e 's@VAR13@'$VAR13'@g' \
-e 's@VAR14@'$VAR14'@g' \
<MID_template.fsf> ${MAINDIR}/FEAT_0${run}.fsf

$FSLDIR/bin/feat ${MAINDIR}/FEAT_0${run}.fsf


OUTDIR=${MAINDIR}/Logs
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
