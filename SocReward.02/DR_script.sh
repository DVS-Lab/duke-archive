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
# # #$ -m ea
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
# #$ -M njc8@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


ICABASE=$1
DESIGN=$2 #what is the name of your design? this will be used to call the .con and .mat files, and also to name the output.

DES_NORM=1
MATRIX=${EXPERIMENT}/Analysis/FSL/Templates/${DESIGN}.mat
CON=${EXPERIMENT}/Analysis/FSL/Templates/${DESIGN}.con

#CON=${EXPERIMENT}/Analysis/Resting_Default-Network/Templates/Gender_n42.con
#why was this pulling from a different directory than $MATRIX?

MAINDIR=${EXPERIMENT}/Analysis/FSL


###Group ICA output###
GROUP_DIR=${MAINDIR}/${ICABASE}.gica
GROUP_MAP=${GROUP_DIR}/groupmelodic.ica/melodic_IC.nii.gz

OUTPUT=${GROUP_DIR}/DR_output_${DESIGN}$UNIQUEID #now the DR output will go into the .gica directory

# njc put filelist here?

#dos2unix $HOME/dual_regression
#/mnt/BIAC/.users/*/munin.dhe.duke.edu/Huettel/SocReward.02
sed -e 's@/mnt/BIAC/.users/.*/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis@'$EXPERIMENT/Analysis'@g' <$GROUP_DIR/.filelist> $GROUP_DIR/files
sh $HOME/dual_regression $GROUP_MAP $DES_NORM $MATRIX $CON 0 $OUTPUT `cat ${GROUP_DIR}/files`
#make sure input list in files matches the input list in design.mat

#Analysis/TaskData/47731/Resting/MELODIC_150/Smooth_6mm/run1.ica/unconfounded_data.nii_Resting_Gender_n42.ica

#rm -r ${EXPERIMENT}/Analysis/TaskData/*/*/MELODIC_150/Smooth_6mm/run*.ica/unconfounded_data.nii_${DESIGN}.ica

OUTDIR=$MAINDIR/Logs
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
