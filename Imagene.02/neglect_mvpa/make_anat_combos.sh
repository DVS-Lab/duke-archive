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
#$ -M david.v.smith@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

MAINDIR=${EXPERIMENT}/Analysis/HighRes_GT/forCNS_LesionMVPA/PyMVPA_DVS/Data
cd $MAINDIR

MASK=$1
COMBOS=$2
#ATLAS=$3

if [ $MASK == "newmask" ]; then
	ROIDIR=ROIs_newmask
elif [ $MASK == "oldmask" ]; then
	ROIDIR=ROIs_oldmask
else
	echo "if statement fail...."
fi

if [ $COMBOS -eq 1 ]; then
	cd ${MAINDIR}/$ROIDIR/combo1
	for i in `ls ROI*.nii.gz`; do
		fslmaths $i -add ${MAINDIR}/zero_mask $i
	done
fi

if [ $COMBOS -eq 3 ]; then
	FILENAME=anatROIs_c3_wJuelich_${MASK}2.txt
	OUTPUT=${MAINDIR}/$ROIDIR/combo3
	mkdir -p $OUTPUT
	
	cat $FILENAME | 
	while read a; do 
	set -- $a
		I1=${MAINDIR}/$ROIDIR/combo1/ROI_${1}
		I2=${MAINDIR}/$ROIDIR/combo1/ROI_${2}
		I3=${MAINDIR}/$ROIDIR/combo1/ROI_${3}
		
		fslmaths $I1 -add $I2 -add $I3 -bin ${OUTPUT}/ROIcombo_${1}_${2}_${3}
	done
fi


if [ $COMBOS -eq 4 ]; then
	FILENAME=anatROIs_c4_wJuelich_${MASK}2.txt
	OUTPUT=${MAINDIR}/$ROIDIR/combo4
	mkdir -p $OUTPUT
	
	cat $FILENAME | 
	while read a; do 
	set -- $a
		I1=${MAINDIR}/$ROIDIR/combo1/ROI_${1}
		I2=${MAINDIR}/$ROIDIR/combo1/ROI_${2}
		I3=${MAINDIR}/$ROIDIR/combo1/ROI_${3}
		I4=${MAINDIR}/$ROIDIR/combo1/ROI_${4}

		fslmaths $I1 -add $I2 -add $I3 -add $I4 -bin ${OUTPUT}/ROIcombo_${1}_${2}_${3}_${4}
	done
fi


if [ $COMBOS -eq 2 ]; then
	FILENAME=anatROIs_c2_wJuelich_${MASK}2.txt
	OUTPUT=${MAINDIR}/$ROIDIR/combo2
	mkdir -p $OUTPUT
	
	cat $FILENAME | 
	while read a; do 
	set -- $a
		I1=${MAINDIR}/$ROIDIR/combo1/ROI_${1}
		I2=${MAINDIR}/$ROIDIR/combo1/ROI_${2}
		
		fslmaths $I1 -add $I2 -bin ${OUTPUT}/ROIcombo_${1}_${2}
	done
fi

OUTDIR=$MAINDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
#rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
