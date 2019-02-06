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

# 
# FSLDIR=/usr/local/packages/fsl-4.1.8
# . ${FSLDIR}/etc/fslconf/fsl.sh
# PATH=${FSLDIR}/bin:${PATH}
# export FSLDIR PATH

ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/Imagene.02
sleep 5s


#ROI=$1

MAINDIR=${EXPERIMENT}/Analysis/TaskData/groupICA_AU/DVS/StriatumParcellation
cd $MAINDIR
LIST=$1

#melodic -i filelist.txt -o striatum10.ica -v --nobet --bgthreshold=3 --tr=2.0 --report --guireport=./report.html --mmthresh=0.5 -a concat -d 10 -m striatum_mask

#melodic -i SubList_${LIST}.txt -o gica_${LIST}_smoothed_masked.ica -v --nobet --tr=1.58 --report --guireport=./gica_${LIST}_smoothed_masked.ica/report.html --bgimage=${FSLDIR}/data/standard/MNI152_T1_2mm_brain -d 10 --mmthresh=0.5 --Ostats -a concat -m StriatumMask_atlas

#melodic -i SubList_${LIST}.txt -o gica_${LIST}_10dim.ica -v --nobet --tr=1.58 --report --guireport=./report.html --bgimage=${FSLDIR}/data/standard/MNI152_T1_2mm_brain -d 10 --mmthresh=0.5 --Ostats -a concat

melodic -i SubList_${LIST}.txt -o gica_${LIST}_autodim.ica -v --nobet --tr=1.58 --report --guireport=./report.html --bgimage=${FSLDIR}/data/standard/MNI152_T1_2mm_brain -d 0 --mmthresh=0.5 --Ostats -a concat


OUTDIR=$MAINDIR/Logs
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