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


ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02
sleep 5s

SUBJ=$1

for RUN in 1 2 3 4; do 
	MAINDIR=/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis
	SUBJDIR=${MAINDIR}/FSL/${SUBJ}/MELODIC_FLIRT/Smooth_5mm/run${RUN}.ica
	DATA=${SUBJDIR}/filtered_func_data.nii.gz
	
	DMN_IC=${MAINDIR}/avu/SR_02_ICA_std/IC_0005.nii.gz
	ECN_IC=${MAINDIR}/avu/SR_02_ICA_std/IC_0003.nii.gz
	LFP_IC=${MAINDIR}/avu/SR_02_ICA_std/IC_0002.nii.gz
	RPF_IC=${MAINDIR}/avu/SR_02_ICA_std/IC_0006.nii.gz
	
	DMN_OUT=${SUBJDIR}/SR_ICA_avu/DMN_ts.txt
	ECN_OUT=${SUBJDIR}/SR_ICA_avu/ECN_ts.txt
	LFP_OUT=${SUBJDIR}/SR_ICA_avu/LFP_ts.txt
	RPF_OUT=${SUBJDIR}/SR_ICA_avu/RFP_ts.txt
	
	fslmeants -i ${DATA} -o ${DMN_OUT} -m ${DMN_IC}
	fslmeants -i ${DATA} -o ${ECN_OUT} -m ${ECN_IC}
	fslmeants -i ${DATA} -o ${LFP_OUT} -m ${LFP_IC}
	fslmeants -i ${DATA} -o ${RFP_OUT} -m ${RFP_IC}

	OUTDIR=$MAINDIR/avu/Logs
	mkdir -p $OUTDIR
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
