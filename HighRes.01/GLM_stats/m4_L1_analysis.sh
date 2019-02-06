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

ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain
if [ $FNIRT -eq 1 ]; then
	PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm/run${RUN}.feat
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model04_FNIRT_new/Smooth_${SMOOTH}mm
	mkdir -p ${MAINOUTPUT}
else
	PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT/Smooth_${SMOOTH}mm/run${RUN}.feat
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model04_FLIRT_new/Smooth_${SMOOTH}mm
	mkdir -p ${MAINOUTPUT}
fi

OUTPUT=${MAINOUTPUT}/run${RUN}
# CONFOUNDEVSFILE=${PRESTATSDIR}/bad_timepoints.txt
# DATA=${PRESTATSDIR}/filtered_func_data.nii.gz
# if [ -e $CONFOUNDEVSFILE ]; then
# 	USECONFOUNDEVS=1
# else
# 	USECONFOUNDEVS=0
# fi
#HighRes.01/Analysis/FSL/1002/PreStats_FNIRT/Smooth_0mm/run1.feat/prestats_phase2_2resample.ica/std_unconfounded_data.nii.gz
CONFOUNDEVSFILE=${PRESTATSDIR}/bad_timepoints.txt
DATA=${PRESTATSDIR}/prestats_phase2_2resample.ica/std_unconfounded_data.nii.gz
USECONFOUNDEVS=0


EVFILES=${MAINDIR}/FSL/EV_files/Model_04/${SUBJ}/run${RUN}

FACELOW=${EVFILES}/Face_Low.txt
FACEMED=${EVFILES}/Face_Med.txt
FACEHIGH=${EVFILES}/Face_High.txt
LANDLOW=${EVFILES}/Land_Low.txt
LANDMED=${EVFILES}/Land_Med.txt
LANDHIGH=${EVFILES}/Land_High.txt
RATING=${EVFILES}/Rating.txt

if [ -e ${OUTPUT}.feat/cluster_mask_zstat22.nii.gz ]; then
	echo "found the right file"
else
	rm -rf ${OUTPUT}.feat
fi

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.feat
fi

NVOLUMES=`fslnvols ${DATA}`

TEMPLATE=${MAINDIR}/FSL/templates/L1_m4.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@RATING@'$RATING'@g' \
-e 's@LANDLOW@'$LANDLOW'@g' \
-e 's@LANDMED@'$LANDMED'@g' \
-e 's@LANDHIGH@'$LANDHIGH'@g' \
-e 's@FACELOW@'$FACELOW'@g' \
-e 's@FACEMED@'$FACEMED'@g' \
-e 's@FACEHIGH@'$FACEHIGH'@g' \
-e 's@CONFOUNDEVSFILE@'$CONFOUNDEVSFILE'@g' \
-e 's@USECONFOUNDEVS@'$USECONFOUNDEVS'@g' \
<$TEMPLATE> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

if [ -d ${OUTPUT}.feat ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi

rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
cp $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/highres2standard.mat
cp ${OUTPUT}.feat/reg/highres2standard.nii.gz ${OUTPUT}.feat/reg/highres.nii.gz
cp $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/example_func2standard.mat
cp ${OUTPUT}.feat/reg/example_func2standard.nii.gz ${OUTPUT}.feat/reg/example_func.nii.gz
cp $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/standard2example_func.mat
cp $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/standard2highres.mat
rm ${OUTPUT}.feat/reg/highres2standard_*
rm ${OUTPUT}.feat/reg/highres_head_to_standard_head.log

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
