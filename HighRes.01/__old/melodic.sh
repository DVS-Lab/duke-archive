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

SUBJ=SUB_SUBNUM_SUB
RUN=SUB_RUN_SUB
SMOOTH=SUB_SMOOTH_SUB
GO=SUB_GO_SUB
FNIRT=SUB_FNIRT_SUB
SETORIGIN=1



MAINDIR=${EXPERIMENT}/Analysis

ANATH=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat
ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain

MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/MELODIC/Smooth_${SMOOTH}mm
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/run${RUN}

PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm/run${RUN}.feat
DATA=${PRESTATSDIR}/filtered_func_data.nii.gz


STANDARD=${MAINDIR}/FSL/MNI152_T1_1.8mm_brain
STANDARDH=${MAINDIR}/FSL/MNI152_T1_1.8mm


if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.ica
fi

# if [ -e ${OUTPUT}.ica/filtered_func_data.nii.gz ]; then
# 	echo "exists: ${OUTPUT}.feat/filtered_func_data.nii.gz"
# 	XX=`fslstats ${OUTPUT}.feat/filtered_func_data.nii.gz -m`
# 	if [ $XX == "nan" ]; then
# 		echo "found $XX in the filtered func file. deleting and starting over..."
# 		rm -rf ${OUTPUT}.ica
# 	fi
# else
# 	echo "does not exist: ${OUTPUT}.feat/filtered_func_data.nii.gz"
# 	rm -rf ${OUTPUT}.ica
# fi

NVOLUMES=`fslnvols ${DATA}`
TEMPLATE=${MAINDIR}/FSL/templates/melodic.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@STANDARD@'$STANDARD'@g' \
<$TEMPLATE> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

#run feat if it has been already
if [ -d ${OUTPUT}.ica ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi

rm ${OUTPUT}.ica/filtered_func_data.nii.gz

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
