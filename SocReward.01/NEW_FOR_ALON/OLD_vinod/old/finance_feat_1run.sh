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
#$ -M smith@biac.duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


SUBJ=$1
RUN=$2
SMOOTH=$3
SESSION=$4
GO=$5

MAINDIR=${EXPERIMENT}/Analysis
SUBJDIR=${MAINDIR}/${SUBJ}/${SESSION}

MAINOUTPUT=${SUBJDIR}/FEAT_${SMOOTH}mmSmooth
OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUTREAL}
fi

mkdir -p ${MAINOUTPUT}

ANAT=${MAINDIR}/${SUBJ}/anat_brain.nii.gz
DATA=${SUBJDIR}/data/run${RUN}.nii.gz
OUTPUT=${MAINOUTPUT}/run${RUN}


RATING=${SUBJDIR}/EVfiles/run${RUN}/ev1.txt
NOCONF=${SUBJDIR}/EVfiles/run${RUN}/ev2.txt
CONFEV=${SUBJDIR}/EVfiles/run${RUN}/ev3.txt
CONFREF=${SUBJDIR}/EVfiles/run${RUN}/ev4.txt
MOTOR=${SUBJDIR}/EVfiles/run${RUN}/ev5.txt

TEMPLATEDIR=${MAINDIR}/Templates
STFILE=${TEMPLATEDIR}/sliceorder.txt

cd ${TEMPLATEDIR}
for i in prestats.fsf; do
 sed -e 's@OUTPUT@'$OUTPUT'@g' \
     -e 's@RATING@'$RATING'@g' \
     -e 's@STFILE@'$STFILE'@g' \
     -e 's@NOCONF@'$NOCONF'@g' \
     -e 's@MOTOR@'$MOTOR'@g' \
     -e 's@CONFREF@'$CONFREF'@g' \
     -e 's@CONFEV@'$CONFEV'@g' \
     -e 's@SMOOTH@'$SMOOTH'@g' \
     -e 's@ANAT@'$ANAT'@g' \
     -e 's@DATA@'$DATA'@g' <$i> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
done

cd ${MAINOUTPUT}

if [ -d "$OUTPUTREAL" ]; then
echo "That one is already done!"
else
feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi

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
