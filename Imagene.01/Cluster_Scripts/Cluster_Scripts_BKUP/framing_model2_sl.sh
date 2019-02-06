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
 
# NOTE:Set OUTDIR HERE. Don't modify/remove/comment-out the value in POST-USER section,
# It won't override the value you set but is a safe default in case you don't set one
# NOTE:Set variables the usual way (the variable constructs in PRE/POST USER sections
# do special things that you don't need
 
#for FSL 4.1
FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh

SUBJ=SUB_SUBNUM_SUB
run=SUB_RUN_SUB
 
echo $FSLDIR
 
#data location and other variables
OUTPUT=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/${SUBJ}_model3b_sl
FEAT1=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run1/${SUBJ}_model3b_run1.feat
FEAT2=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run2/${SUBJ}_model3b_run2.feat
FEAT3=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/run3/${SUBJ}_model3b_run3.feat
OUTDIR=$EXPERIMENT/Analysis/Framing/Logs
 
for i in $EXPERIMENT/Analysis/Framing/Templates/'template_model3_sl.fsf'; do
sed -e 's@OUTPUT@'$OUTPUT'@g' \
    -e 's@FEAT1@'$FEAT1'@g' \
    -e 's@FEAT2@'$FEAT2'@g' \
   -e 's@FEAT3@'$FEAT3'@g' <$i> ${OUTPUT}.fsf
done
 
#run the newly created fsf files
#python $EXPERIMENT/Analysis/Framing/Templates/run_job.py ${MAINOUTPUT}/run${run}/${SUBJ}_model1_run${run}.fsf
feat ${OUTPUT}.fsf

for COPE in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    cd ${OUTPUT}.gfeat
    cd cope${COPE}.feat
    rm -f filtered_func_data.nii.gz
    rm -f var_filtered_func_data.nii.gz
    rm -f stats/res4d.nii.gz
done

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
