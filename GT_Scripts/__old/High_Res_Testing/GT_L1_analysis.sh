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



SUBJ=SUB_SUBNUM_SUB
RUN=SUB_RUN_SUB
SMOOTH=SUB_SMOOTH_SUB
DOFNIRT=SUB_FNIRT_SUB
GO=SUB_GO_SUB

MAINDIR=${EXPERIMENT}/Analysis/HighRes_GT/Rordenhuettel/FSL

if [ $DOFNIRT -eq 1 ]; then
	MAINOUTPUT=${MAINDIR}/${SUBJ}/L1_m1_Stats/Smooth_${SMOOTH}mm_FNIRT
else
	MAINOUTPUT=${MAINDIR}/${SUBJ}/L1_m1_Stats/Smooth_${SMOOTH}mm
fi

mkdir -p $MAINOUTPUT

OUTPUT=${MAINOUTPUT}/run${RUN}
ANAT=$MAINDIR/${SUBJ}/${SUBJ}_anat_brain
COPLANAR=$MAINDIR/${SUBJ}/${SUBJ}_coplanar_brain
DATA=$MAINDIR/${SUBJ}/PreStats/Smooth_${SMOOTH}mm/run${RUN}.feat/filtered_func_data.nii.gz

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.feat
fi

CONFOUNDEVSFILE=${MAINDIR}/${SUBJ}/PreStats/Smooth_${SMOOTH}mm/run${RUN}.feat/bad_timepoints.txt
if [ -e $CONFOUNDEVSFILE ]; then
	USECONFOUNDEVS=1
else
	USECONFOUNDEVS=0
fi

EVFILES=${MAINDIR}/EV_files/Model_01/${SUBJ}/run${RUN}

FACE_H=${EVFILES}/Face_High.txt
FACE_M=${EVFILES}/Face_Medium.txt
FACE_L=${EVFILES}/Face_Low.txt
LAND_H=${EVFILES}/Landscape_High.txt
LAND_M=${EVFILES}/Landscape_Medium.txt
LAND_L=${EVFILES}/Landscapes_Low.txt
RATING=${EVFILES}/Rating.txt

TEMPLATE=${MAINDIR}/Templates/L1_m1_stats.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@COPLANAR@'$COPLANAR'@g' \
-e 's@RATING@'$RATING'@g' \
-e 's@DOFNIRT@'$DOFNIRT'@g' \
-e 's@FACE_H@'$FACE_H'@g' \
-e 's@LAND_H@'$LAND_H'@g' \
-e 's@FACE_M@'$FACE_M'@g' \
-e 's@LAND_M@'$LAND_M'@g' \
-e 's@FACE_L@'$FACE_L'@g' \
-e 's@LAND_L@'$LAND_L'@g' \
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
