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
#$ -M dvs3@duke.edu
# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

# FSLDIR=/usr/local/packages/fsl-4.1.4
# export FSLDIR
# source $FSLDIR/etc/fslconf/fsl.sh
#
SUBJ=$1
ROI=$2
GO=$3
# 
# ls -l
# echo $SUBJ $ROI

#data location and other variables
FSLDATADIR=$EXPERIMENT/Analysis/TaskData/${SUBJ}/Resting/PreStatsOnly_NEW/Smooth_6mm
# cd $FSLDATADIR
# ls -l
ANAT=$EXPERIMENT/Analysis/TaskData/${SUBJ}/${SUBJ}_anat_brain.nii.gz
DATA=${FSLDATADIR}/run1.feat/new_filtered_func_data.nii.gz

MAINOUTPUT=$EXPERIMENT/Analysis/Resting_Default-Network/${SUBJ}
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/${SUBJ}_${ROI}

OUTDIR=$EXPERIMENT/Analysis/Resting_Default-Network/Logs/${SUBJ}
mkdir -p $OUTDIR


if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.feat
fi
sleep 30s

#make regressors
GLOBAL=${FSLDATADIR}/run1.feat/global_filtered.txt
LOCAL=${FSLDATADIR}/run1.feat/${ROI}_local_filtered.txt

REF=${FSLDATADIR}/run1.feat/reg/example_func.nii.gz
MATRIX=${FSLDATADIR}/run1.feat/reg/standard2example_func.mat
FLIRTOUTPUT=${FSLDATADIR}/run1.feat/${ROI}_native
FLIRTINPUT=$EXPERIMENT/Analysis/Resting_Default-Network/ROIs/${ROI}.nii.gz
WB=${FSLDATADIR}/run1.feat/new_mask.nii.gz

if [ ! -e $LOCAL ]; then
	flirt -in ${FLIRTINPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${FLIRTOUTPUT}
	fslmaths ${FLIRTOUTPUT} -thr 0.5 -bin ${FLIRTOUTPUT}
fi

fslmeants -i ${DATA} -o ${LOCAL} -m ${FLIRTOUTPUT}
fslmeants -i ${DATA} -o ${GLOBAL} -m ${WB}


#run analyses
CONFOUNDEVS=${FSLDATADIR}/run1.feat/bad_timepoints.txt
if [ -e $CONFOUNDEVS ]; then
	TEMPLATE=$EXPERIMENT/Analysis/Resting_Default-Network/Templates/resting_Global_ortho_badTRs.fsf
	sed -e 's@DATA@'$DATA'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@GLOBAL@'$GLOBAL'@g' \
	-e 's@LOCAL@'$LOCAL'@g' \
	-e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
	<$TEMPLATE> ${MAINOUTPUT}/${SUBJ}_model${ROI}.fsf
else
	TEMPLATE=$EXPERIMENT/Analysis/Resting_Default-Network/Templates/resting_Global_ortho.fsf
	sed -e 's@DATA@'$DATA'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@GLOBAL@'$GLOBAL'@g' \
	-e 's@LOCAL@'$LOCAL'@g' \
	<$TEMPLATE> ${MAINOUTPUT}/${SUBJ}_model${ROI}.fsf
fi

#run the newly created fsf files
if [ -d $OUTPUT.feat ]; then
	echo "$OUTPUT.feat exists! skipping to the next one"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/${SUBJ}_model${ROI}.fsf
fi

# clean up unwanted files
cd ${OUTPUT}.feat
rm -f filtered_func_data.nii.gz
rm -f stats/res4d.nii.gz


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	
rm -rf $HOME/$JOB_NAME.$JOB_ID.out

RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
