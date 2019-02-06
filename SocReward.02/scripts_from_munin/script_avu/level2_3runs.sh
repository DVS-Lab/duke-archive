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
#$ -M avu4@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


ls /mnt/BIAC/munin4.dhe.duke.edu/Huettel/SocReward.02
sleep 5s

SUBJ=$1

for COPE in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19; do 

MAINDIR=/mnt/BIAC/munin4.dhe.duke.edu/Huettel/SocReward.02/Analysis/avu
MAINOUTPUT=${MAINDIR}/SR02_reward_cueseffects_lvl2_cope${COPE}
mkdir ${MAINOUTPUT}

OUTPUT=${MAINOUTPUT}/${SUBJ}_L2 #where you want L2 output to go
SUBJDIR=${MAINDIR}/SR02_reward_gPPI_DMN_ECN_allDRICs_cueseffects #where all L1s live
TEMPLATEDIR=${MAINDIR}/models/L2
TEMPLATE=${TEMPLATEDIR}/L2_3runs.fsf

INPUT1=${SUBJDIR}/PPI_${SUBJ}_run2.feat/stats/cope${COPE}.nii.gz
INPUT2=${SUBJDIR}/PPI_${SUBJ}_run3.feat/stats/cope${COPE}.nii.gz
INPUT3=${SUBJDIR}/PPI_${SUBJ}_run4.feat/stats/cope${COPE}.nii.gz

cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@INPUT1@'$INPUT1'@g' \
-e 's@INPUT2@'$INPUT2'@g' \
-e 's@INPUT3@'$INPUT3'@g' \
<$TEMPLATE> ${MAINOUTPUT}/${SUBJ}_${COPE}_level2_3runs_edited.fsf

cd ${MAINOUTPUT}

feat ${SUBJ}_${COPE}_level2_3runs_edited.fsf
OUTDIR=$MAINDIR/avu/Logs

done

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
