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
ROI=SUB_ROI_SUB
SETORIGIN=1
FLIP=0

MAINDIR=${EXPERIMENT}/Analysis

ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain
if [ $FNIRT -eq 1 ]; then
	PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm/run${RUN}.feat
	if [ $FLIP -eq 1 ]; then
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model04_FNIRT_PPI_${ROI}_flip/Smooth_${SMOOTH}mm
	else
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model04_FNIRT_PPI_${ROI}_invwarp/Smooth_${SMOOTH}mm
	fi

	mkdir -p ${MAINOUTPUT}
else
	PRESTATSDIR=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT/Smooth_${SMOOTH}mm/run${RUN}.feat
	if [ $FLIP -eq 1 ]; then
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model04_FLIRT_PPI_${ROI}_flip/Smooth_${SMOOTH}mm
	else
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model04_FLIRT_PPI_${ROI}_invwarp/Smooth_${SMOOTH}mm
	fi
	mkdir -p ${MAINOUTPUT}
fi

OUTPUT=${MAINOUTPUT}/run${RUN}
CONFOUNDEVSFILE=${PRESTATSDIR}/bad_timepoints.txt
DATA=${PRESTATSDIR}/filtered_func_data.nii.gz
if [ -e $CONFOUNDEVSFILE ]; then
	USECONFOUNDEVS=1
else
	USECONFOUNDEVS=0
fi

EVFILES=${MAINDIR}/FSL/EV_files/Model_04_PPI/${SUBJ}/run${RUN}

FACE_MED=${EVFILES}/Face_Med.txt
FACE_HIGHPLUSLOW=${EVFILES}/Face_High_plus_Low.txt
FACE_HIGHMINUSLOW=${EVFILES}/Face_High_minus_Low.txt
LAND_MED=${EVFILES}/Land_Med.txt
LAND_HIGHPLUSLOW=${EVFILES}/Land_High_plus_Low.txt
LAND_HIGHMINUSLOW=${EVFILES}/Land_High_minus_Low.txt
RATING=${EVFILES}/Rating.txt

if [ -e ${OUTPUT}.feat/cluster_mask_zstat7.nii.gz ]; then
	echo "found the right file"
else
	rm -rf ${OUTPUT}.feat
fi

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.feat
fi

LOCAL=${PRESTATSDIR}/${ROI}_local_filtered.txt
rm -rf $LOCAL

REF=${PRESTATSDIR}/reg/example_func.nii.gz
MATRIX=${PRESTATSDIR}/reg/standard2example_func.mat
FLIRTINPUT=$EXPERIMENT/Analysis/FSL/ROIs/R_${ROI}_peak_5mm.nii.gz
WARPFILE=${PRESTATSDIR}/reg/highres2standard_warp.nii.gz
# if [ $FNIRT -eq 1 ]; then
# 	FLIRTOUTPUT=${PRESTATSDIR}/${ROI}_native_invwarp
# 	invwarp -w $WARPFILE -o ${ROI}_invwarp -r $REF
# else
# 	FLIRTOUTPUT=${PRESTATSDIR}/${ROI}_native
# 	flirt -in ${FLIRTINPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${FLIRTOUTPUT}
# fi
#invwarp -w warpvol -o invwarpvol -r refvol
FLIRTOUTPUT=${PRESTATSDIR}/${ROI}_native
flirt -in ${FLIRTINPUT} -ref ${REF} -applyxfm -init ${MATRIX} -out ${FLIRTOUTPUT}

fslmaths ${FLIRTOUTPUT} -thr 0.2 -bin ${FLIRTOUTPUT}
fslmeants -i ${DATA} -o ${LOCAL} -m ${FLIRTOUTPUT}

NVOLUMES=`fslnvols ${DATA}`

#reassign ROI. e.g., use PPA time course with face stimuli (and not land stim)
if [ $FLIP -eq 1 ]; then
	if [ "$ROI" == "PPA" ]; then
		ROI=FFA
	else
		ROI=PPA
	fi
fi
TEMPLATE=${MAINDIR}/FSL/templates/L1_m4_PPI_${ROI}_PSY.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@LOCAL@'$LOCAL'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@RATING@'$RATING'@g' \
-e 's@FACE_HIGHPLUSLOW@'$FACE_HIGHPLUSLOW'@g' \
-e 's@LAND_MED@'$LAND_MED'@g' \
-e 's@FACE_HIGHMINUSLOW@'$FACE_HIGHMINUSLOW'@g' \
-e 's@LAND_HIGHMINUSLOW@'$LAND_HIGHMINUSLOW'@g' \
-e 's@FACE_MED@'$FACE_MED'@g' \
-e 's@LAND_HIGHPLUSLOW@'$LAND_HIGHPLUSLOW'@g' \
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
