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
#$ -m ea
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
#$ -M smith@biac.duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


SUBJ=$1
RUN=$2

PSEQ="sense_spiral-in"
FSLDATADIR2=${EXPERIMENT}/Analysis/DavidPaulsen/Data/${SUBJ}_data/${PSEQ}

ANATDIR=${EXPERIMENT}/Analysis/DavidPaulsen/Data/${SUBJ}_data
cd $ANATDIR

bet ${SUBJ}_anat.nii ${SUBJ}_anat_brain -f 0.35

bet ${SUBJ}_anat.nii ${SUBJ}_anat_0.05 -f 0.05
bet ${SUBJ}_anat.nii ${SUBJ}_anat_0.50 -f 0.50
bet ${SUBJ}_anat.nii ${SUBJ}_anat_0.99 -f 0.99


ANAT=${EXPERIMENT}/Analysis/DavidPaulsen/${SUBJ}_data/${SUBJ}_anat_brain.nii.gz
TEMPLATEDIR=${EXPERIMENT}/Analysis/DavidPaulsen
DATA=${FSLDATADIR2}/run${RUN}.nii
MAINOUTPUT=${FSLDATADIR2}/${SUBJ}_test
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN}_test
echo $MAINOUTPUT
echo $OUTPUT
FSLEVDIR=${EXPERIMENT}/Analysis/DavidPaulsen/EVfiles/ev_txt
 
RIGHT=${FSLEVDIR}/LR_noinhale_right.txt
LEFT=${FSLEVDIR}/LR_noinhale_left.txt


cd ${TEMPLATEDIR}
for i in 'AnalysisTemplates.fsf'; do
 sed -e 's@OUTPUT@'$OUTPUT'@g' \
     -e 's@RIGHT@'$RIGHT'@g' \
     -e 's@LEFT@'$LEFT'@g' \
     -e 's@ANAT@'$ANAT'@g' \
     -e 's@DATA@'$DATA'@g' <$i> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
done

   
cd ${MAINOUTPUT}
feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf

echo $DATA
OUTDIR=${MAINOUTPUT}

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
