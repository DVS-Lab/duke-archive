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
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
source $FSLDIR/etc/fslconf/fsl.sh

SUBJ=SUB_SUBNUM_SUB
RUN=SUB_RUN_SUB
SMOOTH=SUB_SMOOTH_SUB
TASK=SUB_TASK_SUB
GO=SUB_GO_SUB


if [ $SUBJ -eq 47964 ]; then #why is this true? FATASS didn't fit in the scanner
	exit
fi

if [ $SUBJ -eq 47945 ] && [ $RUN -eq 3 ] && [ "$TASK" == "MID" ]; then
	echo "this run was never there..."
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48152 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48150 ]; then
	echo "Resting DNE"
	exit
fi


if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48156 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48061 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48271 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48123 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48129 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Gambling" ] && [ $RUN -eq 3 ] && [ $SUBJ -eq 48129 ]; then
	echo "gambling run 3 DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48197 ]; then
	echo "Resting DNE"
	exit
fi


MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}/${TASK}/PreStatsOnly/Smooth_${SMOOTH}mm
OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
DATA=${SUBJDIR}/${TASK}/run${RUN}.nii.gz


NDISDAQS=6

if [ ! -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
	fsl_motion_outliers ${DATA} ${NDISDAQS} ${OUTPUTREAL}/bad_timepoints.txt
else
	echo "already done: ${OUTPUTREAL}/bad_timepoints.txt"
fi

OUTDIR=${MAINDIR}/ClusterLogs_NEW_motion/GO_${GO}
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
