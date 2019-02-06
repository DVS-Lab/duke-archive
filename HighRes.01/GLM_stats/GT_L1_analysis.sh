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
SETORIGIN=SUB_SETORIGIN_SUB

MAINDIR=${EXPERIMENT}/Analysis

if [ $SETORIGIN -eq 1 ]; then
	ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain
	if [ $FNIRT -eq 1 ]; then
		PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm/run${RUN}.feat
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model02_FNIRT/Smooth_${SMOOTH}mm
		mkdir -p ${MAINOUTPUT}
	else
		PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT/Smooth_${SMOOTH}mm/run${RUN}.feat
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model02_FLIRT/Smooth_${SMOOTH}mm
		mkdir -p ${MAINOUTPUT}
	fi
else
	ANAT=${MAINDIR}/NIFTI2/$SUBJ/${SUBJ}_anat_brain
	if [ $FNIRT -eq 1 ]; then
		PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT_noSO/Smooth_${SMOOTH}mm/run${RUN}.feat
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model02_FNIRT_noSO/Smooth_${SMOOTH}mm
		mkdir -p ${MAINOUTPUT}
	else
		PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT_noSO/Smooth_${SMOOTH}mm/run${RUN}.feat
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model02_FLIRT_noSO/Smooth_${SMOOTH}mm
		mkdir -p ${MAINOUTPUT}
	fi
fi

STANDARD=${MAINDIR}/FSL/MNI152_T1_1mm_brain
OUTPUT=${MAINOUTPUT}/run${RUN}
CONFOUNDEVSFILE=${PRESTATSDIR}/bad_timepoints.txt
DATA=${PRESTATSDIR}/filtered_func_data.nii.gz
if [ -e $CONFOUNDEVSFILE ]; then
	USECONFOUNDEVS=1
else
	USECONFOUNDEVS=0
fi

EVFILES=${MAINDIR}/FSL/EV_files/Model_02/${SUBJ}/run${RUN}
FACECONSTANT=${EVFILES}/Face_constant.txt
FACEPARAMETRIC=${EVFILES}/Face_parametric.txt
LANDCONSTANT=${EVFILES}/Land_constant.txt
LANDPARAMETRIC=${EVFILES}/Land_parametric.txt
RATING=${EVFILES}/Rating.txt

NVOLUMES=`fslnvols ${DATA}`

TEMPLATE=${MAINDIR}/FSL/templates/L1_parametric.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@RATING@'$RATING'@g' \
-e 's@LANDPARAMETRIC@'$LANDPARAMETRIC'@g' \
-e 's@LANDCONSTANT@'$LANDCONSTANT'@g' \
-e 's@FACEPARAMETRIC@'$FACEPARAMETRIC'@g' \
-e 's@FACECONSTANT@'$FACECONSTANT'@g' \
-e 's@STANDARD@'$STANDARD'@g' \
-e 's@CONFOUNDEVSFILE@'$CONFOUNDEVSFILE'@g' \
-e 's@USECONFOUNDEVS@'$USECONFOUNDEVS'@g' \
<$TEMPLATE> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

if [ -d ${OUTPUT}.feat ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi

rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
cp -r ${PRESTATSDIR}/reg ${OUTPUT}.feat/reg

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
