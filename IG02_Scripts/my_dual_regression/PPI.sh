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

SUBJ=$1

if [ $SUBJ -eq 10315 -o $SUBJ -eq 10424 -o $SUBJ -eq 10794 -o $SUBJ -eq 11328 -o $SUBJ -eq 11371 -o $SUBJ -eq 12294 -o $SUBJ -eq 12665 -o $SUBJ -eq 12758 ]; then 
	RUN=2
elif [ $SUBJ -eq 11067 -o $SUBJ -eq 11245 -o $SUBJ -eq 12988 ]; then
	RUN=3
else
	RUN=1
fi

SMOOTH=6
MAINDIR=${EXPERIMENT}/Analysis/TaskData
REGDIR=${MAINDIR}/${SUBJ}/MID/MELODIC_FNIRT/Smooth_${SMOOTH}mm/run${RUN}.ica/reg
DATADIR=${MAINDIR}/${SUBJ}/MID/MELODIC_150/Smooth_${SMOOTH}mm/run${RUN}.ica
DATA=${DATADIR}/unconfounded_data.nii.gz


EVDIR=${MAINDIR}/groupICA_AU/DVS/StriatumParcellation/PPI_EVs_znormed
ROI01=${EVDIR}/${SUBJ}/ROI01.txt
ROI02=${EVDIR}/${SUBJ}/ROI02.txt
ROI03=${EVDIR}/${SUBJ}/ROI03.txt
ROI04=${EVDIR}/${SUBJ}/ROI04.txt
ROI05=${EVDIR}/${SUBJ}/ROI05.txt
ROI06=${EVDIR}/${SUBJ}/ROI06.txt
ROI07=${EVDIR}/${SUBJ}/ROI07.txt
ROI08=${EVDIR}/${SUBJ}/ROI08.txt
ROI09=${EVDIR}/${SUBJ}/ROI09.txt
ROI10=${EVDIR}/${SUBJ}/ROI10.txt
DUMMY01=${EVDIR}/${SUBJ}/dummy01.txt
DUMMY02=${EVDIR}/${SUBJ}/dummy02.txt
DUMMY03=${EVDIR}/${SUBJ}/dummy03.txt
DUMMY04=${EVDIR}/${SUBJ}/dummy04.txt
if [ -e $DUMMY04 ]; then
	DUM04_SHAPE=3
else
	DUM04_SHAPE=10
fi
DUMMY05=${EVDIR}/${SUBJ}/dummy05.txt
if [ -e $DUMMY05 ]; then
	DUM05_SHAPE=3
else
	DUM05_SHAPE=10
fi
CONTRAST=${EVDIR}/${SUBJ}/reward_contrast.txt
CONSTANT=${EVDIR}/${SUBJ}/reward_constant.txt


MAINOUTPUT=${MAINDIR}/groupICA_AU/DVS/StriatumParcellation/NewPPI/$SUBJ
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/zPPI

TEMPLATEDIR=${MAINDIR}/groupICA_AU/DVS/StriatumParcellation/NewPPI
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@CONSTANT@'$CONSTANT'@g' \
-e 's@CONTRAST@'$CONTRAST'@g' \
-e 's@DUM04_SHAPE@'$DUM04_SHAPE'@g' \
-e 's@DUM05_SHAPE@'$DUM05_SHAPE'@g' \
-e 's@DUMMY01@'$DUMMY01'@g' \
-e 's@DUMMY02@'$DUMMY02'@g' \
-e 's@DUMMY03@'$DUMMY03'@g' \
-e 's@DUMMY04@'$DUMMY04'@g' \
-e 's@DUMMY05@'$DUMMY05'@g' \
-e 's@ROI01@'$ROI01'@g' \
-e 's@ROI02@'$ROI02'@g' \
-e 's@ROI03@'$ROI03'@g' \
-e 's@ROI04@'$ROI04'@g' \
-e 's@ROI05@'$ROI05'@g' \
-e 's@ROI06@'$ROI06'@g' \
-e 's@ROI07@'$ROI07'@g' \
-e 's@ROI08@'$ROI08'@g' \
-e 's@ROI09@'$ROI09'@g' \
-e 's@ROI10@'$ROI10'@g' \
<PPI_model.fsf> ${MAINOUTPUT}/zFEAT.fsf

feat ${MAINOUTPUT}/zFEAT.fsf

cp -r ${REGDIR} ${OUTPUT}.feat/.


mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
