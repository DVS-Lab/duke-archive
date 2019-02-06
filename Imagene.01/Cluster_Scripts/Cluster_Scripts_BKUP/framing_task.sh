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
#$ -M YOUR_EMAIL@biac.duke.edu
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --
# User script goes here
 
# NOTE:Set OUTDIR HERE. Don't modify/remove/comment-out the value in POST-USER section,
# It won't override the value you set but is a safe default in case you don't set one
# NOTE:Set variables the usual way (the variable constructs in PRE/POST USER sections
# do special things that you don't need
 
#for FSL 4.1
FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh
#
SUBJ=SUB_SUBNUM_SUB
run=SUB_RUN_SUB
 
#data location and other variables
FSLDATADIR=$EXPERIMENT/Analysis/TaskData/${SUBJ}/Framing/PreStatsOnly/Smooth_10mm
FSLEVDIR=$EXPERIMENT/Analysis/Framing/EVfiles/${SUBJ}
ANAT=$EXPERIMENT/Analysis/TaskData/${SUBJ}/${SUBJ}_anat_brain.nii.gz
MAINOUTPUT=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}
OUTDIR=$EXPERIMENT/Analysis/Framing/Logs

#mkdir -p ${MAINOUTPUT}/run${run}

EV1=${FSLEVDIR}/run${run}/${SUBJ}_char_cue_run${run}.txt
EV2=${FSLEVDIR}/run${run}/${SUBJ}_self_cue_run${run}.txt
EV3=${FSLEVDIR}/run${run}/${SUBJ}_char_gain_run${run}.txt
EV4=${FSLEVDIR}/run${run}/${SUBJ}_char_loss_run${run}.txt
EV5=${FSLEVDIR}/run${run}/${SUBJ}_self_gain_run${run}.txt
EV6=${FSLEVDIR}/run${run}/${SUBJ}_self_loss_run${run}.txt
OUTPUT=${MAINOUTPUT}/run${run}/${SUBJ}_model1b_run${run}
DATA=${FSLDATADIR}/run${run}.feat/new_filtered_func_data.nii.gz 
 
for i in $EXPERIMENT/Analysis/Framing/Templates/'template_model1.fsf'; do
sed -e 's@DATA@'$DATA'@g' \
    -e 's@ANAT@'$ANAT'@g' \
    -e 's@OUTPUT@'$OUTPUT'@g' \
    -e 's@EV1@'$EV1'@g' \
    -e 's@EV2@'$EV2'@g' \
    -e 's@EV3@'$EV3'@g' \
    -e 's@EV4@'$EV4'@g' \
    -e 's@EV5@'$EV5'@g' \
   -e 's@EV6@'$EV6'@g' <$i> ${MAINOUTPUT}/run${run}/${SUBJ}_model1b_run${run}.fsf
done
 
#run the newly created fsf files
#python $EXPERIMENT/Analysis/Framing/Templates/run_job.py ${MAINOUTPUT}/run${run}/${SUBJ}_model1_run${run}.fsf
feat ${MAINOUTPUT}/run${run}/${SUBJ}_model1b_run${run}.fsf
 
# clean up unwanted files
cd ${OUTPUT}.feat
rm -f filtered_func_data.nii.gz
rm -f stats/res4d.nii.gz
#OUTPUT1=${MAINOUTPUT}/${SUBJ}_model1_sl+.gfeat
#OUTPUT2=${MAINOUTPUT}/${SUBJ}_model1_sl.gfeat
#mv ${OUTPUT1} ${OUTPUT2}

# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis}  #output directory
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$SUBJ_$JOB_NAME.$JOB_ID.txt
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
