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
# #$ -M david.v.smith@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/Imagene.02
sleep 5s

MAINDIR=${EXPERIMENT}/Analysis/HighRes_GT/forCNS_LesionMVPA/PyMVPA_DVS
cd $MAINDIR

ROI_LIST="SUB_ROILIST_SUB"
NCOMBO=SUB_NCOMBO_SUB
ID=SUB_ID_SUB
TESTNAME=SUB_TESTNAME_SUB
DATATYPE=SUB_DATATYPE_SUB
PERM=SUB_PERM_SUB

MAINOUTPUT=${MAINDIR}/PythonFiles/$NCOMBO/${TESTNAME}
mkdir -p $MAINOUTPUT

sed -e 's@MAINDIR@'$MAINDIR'@g' \
-e 's@SED_ROILIST_SED@'"$ROI_LIST"'@g' \
-e 's@SED_NCOMBO_SED@'$NCOMBO'@g' \
-e 's@SED_TESTNAME_SED@'$TESTNAME'@g' \
-e 's@SED_DATATYPE_SED@'$DATATYPE'@g' \
-e 's@SED_PERM_SED@'$PERM'@g' \
<template_PYMVPA_ROI_equal_weight.py> ${MAINOUTPUT}/mvpa_combo${NCOMBO}_${ID}_${TESTNAME}_${DATATYPE}_equal_${PERM}.py

python ${MAINOUTPUT}/mvpa_combo${NCOMBO}_${ID}_${TESTNAME}_${DATATYPE}_equal_${PERM}.py
rm ${MAINOUTPUT}/mvpa_combo${NCOMBO}_${ID}_${TESTNAME}_${DATATYPE}_equal_${PERM}.py



#numpy load/read text



OUTDIR=$MAINDIR/Logs/equal/$MASK/$NCOMBO
mkdir -p $OUTDIR


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
