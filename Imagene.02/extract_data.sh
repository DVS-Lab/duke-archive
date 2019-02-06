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
# #$ -m ea
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
# #$ -M jac44@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


ls /mnt/BIAC/munin3.dhe.duke.edu/Huettel/Imagene.02
sleep 5s

FSLDIR=/usr/local/packages/fsl-4.1.8
 . ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH


SUBJ=$1
TASK=$2
RUN=$3
GO=1


MAINDIR=/mnt/BIAC/munin3.dhe.duke.edu/Huettel/Imagene.02/Analysis

TPJ=${MAINDIR}/AU_connectivity/DVS/TPJparcellation/func_LTPJ_mA.nii.gz
PCC=${MAINDIR}/AU_connectivity/DVS/TPJparcellation/func_PCC_mA.nii.gz

#task
DATADIR=${MAINDIR}/TaskData/${SUBJ}/${TASK}/MELODIC_FLIRT/Smooth_6mm/run${RUN}.ica
DATA=${DATADIR}/std_unconfounded_data_flirt_2mm.nii.gz
fslmaths ${DATA} -mas ${TPJ} ${DATADIR}/funcTPJ_std_unconfounded_data_flirt_2mm
fslmaths ${DATA} -mas ${PCC} ${DATADIR}/funcPCC_std_unconfounded_data_flirt_2mm

#rest
DATADIR=${MAINDIR}/TaskData/${SUBJ}/Resting/MELODIC_FLIRT/Smooth_6mm/run1.ica
DATA=${DATADIR}/std_unconfounded_data_flirt_2mm.nii.gz
fslmaths ${DATA} -mas ${TPJ} ${DATADIR}/funcTPJ_std_unconfounded_data_flirt_2mm
fslmaths ${DATA} -mas ${PCC} ${DATADIR}/funcPCC_std_unconfounded_data_flirt_2mm


OUTDIR=${MAINDIR}/AU_connectivity/DVS/TPJparcellation/Logs_Bacon
mkdir -p $OUTDIR

# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
