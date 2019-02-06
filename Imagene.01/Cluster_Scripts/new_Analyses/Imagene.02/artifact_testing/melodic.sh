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


SUBJ_FULL=20100408_10680
RUN=$1
SET_TR=$2

MAINFUNCDIR=${EXPERIMENT}/Data

cd ${MAINFUNCDIR}/${SUBJ_FULL}/${RUN}
rm -rf reoriented_${RUN}.bxh
rm -rf reoriented_${RUN}.dat
bxhreorient --orientation LAS ${RUN}.bxh reoriented_${RUN}.bxh
extractsliceorder --fsl --overwrite reoriented_${RUN}.bxh sliceorder.txt

rm -rf reoriented_${RUN}.nii.gz
bxh2analyze -s -b --niigz reoriented_${RUN}.bxh reoriented_${RUN}
echo "bxh2analyze -s -b --niigz reoriented_run${RUN}.bxh reoriented_${RUN}"
rm -rf reoriented_${RUN}.bxh
rm -rf reoriented_${RUN}.dat



MAINDIR=${EXPERIMENT}/Analysis/TaskData
DATADIR=${MAINFUNCDIR}/${SUBJ_FULL}/${RUN}

DATA=${DATADIR}/reoriented_${RUN}.nii.gz
OUTPUT=${DATADIR}/${RUN}
SO_FILE=${DATADIR}/sliceorder.txt

NVOLUMES=`fslnvols ${DATA}`


NDISDAQS=8
TEMPLATEDIR=${MAINDIR}/Templates
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@NDISDAQS@'$NDISDAQS'@g' \
-e 's@SO_FILE@'$SO_FILE'@g' \
-e 's@SET_TR@'$SET_TR'@g' \
<melodic.fsf> ${DATADIR}/FEAT_${RUN}.fsf

feat ${DATADIR}/FEAT_${RUN}.fsf


OUTDIR=${MAINDIR}/Logs/artifact
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
