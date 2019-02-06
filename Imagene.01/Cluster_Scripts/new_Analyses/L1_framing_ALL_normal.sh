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
# #$ -m ea
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
# #$ -M smith@biac.duke.edu
# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


# FSLDIR=/usr/local/fsl-4.1.4-centos4_64
# export FSLDIR
# source $FSLDIR/etc/fslconf/fsl.sh

SUBJ=SUB_SUBNUM_SUB
run=SUB_RUN_SUB
MODEL=SUB_MODEL_SUB
GO=SUB_GO_SUB

#data location and other variables
FSLDATADIR=$EXPERIMENT/Analysis/TaskData/${SUBJ}/Framing/PreStatsOnly_NEW2/Smooth_6mm
ANAT=$EXPERIMENT/Analysis/TaskData/${SUBJ}/${SUBJ}_anat_brain.nii.gz
DATA=${FSLDATADIR}/run${run}.feat/filtered_func_data.nii.gz
MAINOUTPUT=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/corrected_NoLapses/model${MODEL}
OUTPUT=${MAINOUTPUT}/run${run}
mkdir -p ${MAINOUTPUT}

OUTDIR=$EXPERIMENT/Analysis/Framing/Logs/July2012/L1_m${MODEL}_NEW_go_${GO}/$SUBJ
mkdir -p $OUTDIR

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.feat
fi

FILE_CHECK=${OUTPUT}.feat/cluster_mask_zstat1.nii.gz
if [ -e $FILE_CHECK ]; then
	echo "analysis completed..."
else
	rm -rf ${OUTPUT}.feat
fi



if [ $SUBJ -eq 47731 ] && [ $run -eq 1 ]; then
	NVOLUMES=128
else
	NVOLUMES=174
fi

FSLEVDIR=$EXPERIMENT/Analysis/Framing/EVfiles6/Model11_NoLapses/${SUBJ}



CHARGAIN=${FSLEVDIR}/run${run}/${SUBJ}_char_gain_run${run}.txt
CHARLOSS=${FSLEVDIR}/run${run}/${SUBJ}_char_loss_run${run}.txt
SELFGAIN=${FSLEVDIR}/run${run}/${SUBJ}_self_gain_run${run}.txt
SELFLOSS=${FSLEVDIR}/run${run}/${SUBJ}_self_loss_run${run}.txt

CUE=${FSLEVDIR}/run${run}/${SUBJ}_cue_run${run}.txt
ENDOWMENT=${FSLEVDIR}/run${run}/${SUBJ}_endowment_run${run}.txt
EXPECTEDVALUE=${FSLEVDIR}/run${run}/${SUBJ}_expected_value_run${run}.txt

MISSES=${FSLEVDIR}/run${run}/${SUBJ}_misses_run${run}.txt

CONFOUNDEVSFILE=${FSLDATADIR}/run${run}.feat/for_confound.txt
if [ -e $CONFOUNDEVS ]; then
	USECONFOUNDEVS=1
else
	USECONFOUNDEVS=0
fi

if [ -e $MISSES ]; then
	EVSHAPE=3
else
	EVSHAPE=10
fi

TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L1_model11.fsf
NEWFSFFILE=${MAINOUTPUT}/run${run}.fsf
sed -e 's@DATA@'$DATA'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@CHARGAIN@'$CHARGAIN'@g' \
-e 's@CHARLOSS@'$CHARLOSS'@g' \
-e 's@SELFGAIN@'$SELFGAIN'@g' \
-e 's@SELFLOSS@'$SELFLOSS'@g' \
-e 's@MISSES@'$MISSES'@g' \
-e 's@CUE@'$CUE'@g' \
-e 's@EXPECTEDVALUE@'$EXPECTEDVALUE'@g' \
-e 's@ENDOWMENT@'$ENDOWMENT'@g' \
-e 's@EVSHAPE@'$EVSHAPE'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@USECONFOUNDEVS@'$USECONFOUNDEVS'@g' \
-e 's@CONFOUNDEVSFILE@'$CONFOUNDEVSFILE'@g' \
<$TEMPLATE> $NEWFSFFILE


#run the newly created fsf files
if [ -d $OUTPUT.feat ]; then
	echo "$OUTPUT.feat exists! skipping to the next one"
else
	$FSLDIR/bin/feat $NEWFSFFILE
fi


# clean up unwanted files
rm -f ${OUTPUT}.feat/filtered_func_data.nii.gz
rm -f ${OUTPUT}.feat/stats/res4d.nii.gz
rm -f ${OUTPUT}.feat/stats/corrections.nii.gz


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
