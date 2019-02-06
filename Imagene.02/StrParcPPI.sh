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


# -- two inputs
S=$1 #subject number
x=$2
d=$3

MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBDIR=${MAINDIR}/${S}/Resting
DATA=${SUBDIR}/prestats1_4mmSUSAN_clean.feat/filtered_func_data.nii.gz

MAINOUTPUT=${MAINDIR}/StrParc/FSL/${S}
OUTPUT=${MAINOUTPUT}/L1_RestingDim0${d}_s${x}_uni
rm -rf ${OUTPUT}.feat

#EVDIR=${MAINDIR}/StrParc/EVs_nets_rest
#NET1=${EVDIR}/${S}/net01_run1.txt
#NET2=${EVDIR}/${S}/net02_run1.txt
#NET3=${EVDIR}/${S}/net03_run1.txt
#NET4=${EVDIR}/${S}/net04_run1.txt

EVDIR=${MAINOUTPUT}/L1_RestingDim0${d}_s${x}.feat
NET1=${EVDIR}/uni_ts_roi1.txt
NET2=${EVDIR}/uni_ts_roi2.txt
NET3=${EVDIR}/uni_ts_roi3.txt
NET4=${EVDIR}/uni_ts_roi4.txt

TEMPLATE=${MAINDIR}/StrParc/templates/L1_restingDim0${d}.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NET1@'$NET1'@g' \
-e 's@NET2@'$NET2'@g' \
-e 's@NET3@'$NET3'@g' \
-e 's@NET4@'$NET4'@g' \
<$TEMPLATE> ${MAINOUTPUT}/L1_resting_dim0${d}.fsf
feat ${MAINOUTPUT}/L1_resting_dim0${d}.fsf

rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz

OUTDIR=${MAINDIR}/Logs/resting
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