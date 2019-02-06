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
TASK=SUB_TASK_SUB
GO=SUB_GO_SUB


if [ $SUBJ -eq 47964 ]; then #why is this true? FATASS didn't fit in the scanner
	SKIP=1
fi

if [ $SUBJ -eq 47945 ] && [ $RUN -eq 3 ] && [ "$TASK" == "MID" ]; then
	echo "this run was never there..."
	SKIP=1
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48152 ]; then
	echo "Resting DNE"
	SKIP=1
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48150 ]; then
	echo "Resting DNE"
	SKIP=1
fi


if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48156 ]; then
	echo "Resting DNE"
	SKIP=1
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48061 ]; then
	echo "Resting DNE"
	SKIP=1
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48271 ]; then
	echo "Resting DNE"
	SKIP=1
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48123 ]; then
	echo "Resting DNE"
	SKIP=1
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48129 ]; then
	echo "Resting DNE"
	SKIP=1
fi

if [ "$TASK" == "Gambling" ] && [ $RUN -eq 3 ] && [ $SUBJ -eq 48129 ]; then
	echo "gambling run 3 DNE"
	SKIP=1
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48197 ]; then
	echo "Resting DNE"
	SKIP=1
fi


#--------end exceptions list-------


MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}/${TASK}/MELODIC_150/Smooth_${SMOOTH}mm

OUTPUTREAL=${MAINOUTPUT}/run${RUN}.ica
INDATA=${OUTPUTREAL}/filtered_func_data.nii.gz
NVOLUMES=`fslnvols $INDATA`
OUTDATA=${OUTPUTREAL}/unconfounded_data.nii.gz
if [ $GO -eq 1 ]; then
	rm -rf $OUTDATA
fi
if [ -e $OUTDATA ]; then
	SKIP=1
fi
preMAT=${OUTPUTREAL}/for_confound.txt
postMAT=${OUTPUTREAL}/for_unconfound.mat
if [ $SKIP -eq 1 ]; then
	echo "not running unconfound for exceptions or ones that are already done..."
else
	TEMPLATEDIR=${MAINDIR}/Templates
	cd ${TEMPLATEDIR}
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@DATA@'$INDATA'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	-e 's@UNCONFOUNDFILE@'$preMAT'@g' \
	<make_confoundmat.fsf> ${OUTPUTREAL}/for_unconfound.fsf
	feat_model ${OUTPUTREAL}/for_unconfound ${preMAT}
	unconfound ${INDATA} ${OUTDATA} ${postMAT}
fi

OUTDIR=$MAINDIR/Logs/unconfound
mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
if [ -e $OUTDIR/$JOB_NAME.$JOB_ID.out ]; then
rm $HOME/$JOB_NAME.$JOB_ID.out
fi
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
