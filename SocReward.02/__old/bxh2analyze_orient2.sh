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
#$ -M dvs3@duke.edu
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --
# User script goes here
 
# Need to input global EXPERIMENT, and inputs BXHINFILE, OUTDIR and OUTPRE
# BXHINFILE is the input file to convert
# OUTDIR is where the output folder will go
# OUTPRE is the output prefix of the data
# Example:
# qsub -v EXPERIMENT=Dummy.01 qsub_bxh2analyze \
# EXPERIMENT/Data/Func/99999/run01/run001.bxh EXPERIMENT/Data/Func/99999/fsl4D run01
 
 
 
for LIST in "20071010_33744 33744 8" "20070803_33467 33467 8"; do

set -- $LIST
SUBJ_FULL=$1
SUBJ=$2
NUMRUNS=$3

MAINFUNCDIR=${EXPERIMENT}/Data/Func
MAINANATDIR=${EXPERIMENT}/Data/Anat
NEWANATDIR=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat
mkdir -p $NEWANATDIR

cd $MAINANATDIR/${SUBJ_FULL}/series*00



bxhreorient --orientation LAS series*.bxh ${SUBJ}_reoriented_anat.bxh

bxh2analyze -s --nii ${SUBJ}_reoriented_anat.bxh $NEWANATDIR/${SUBJ}_anat

for RUNS in `seq $NUMRUNS`; do
if [ "$SUBJ" -eq 33744 ]; then
let "RUN=${RUNS}+0"
let "RUN2=${RUNS}+1"
	if [ $RUN2 -gt 6 ]; then
	AOUTPUTDIR=${EXPERIMENT}/Analysis/Cluster/ActiveTask/${SUBJ}
	mkdir -p ${AOUTPUTDIR}
	cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUN}
	bxhreorient --orientation LAS run*${RUN}.bxh reoriented_run${RUN2}.bxh
	bxh2analyze -s --nii reoriented_run${RUN2}.bxh ${AOUTPUTDIR}/run${RUN2}
	else
	POUTPUTDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}
	mkdir -p ${POUTPUTDIR}
	cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUN}
	bxhreorient --orientation LAS run*${RUN}.bxh reoriented_run${RUN2}.bxh
	bxh2analyze -s --nii reoriented_run${RUN2}.bxh ${POUTPUTDIR}/run${RUN2}
	fi
elif [ "$SUBJ" -eq 33467 ]; then
let "RUN=${RUNS}+2"
let "RUN2=${RUNS}+1"
 	if [ $RUN2 -gt 6 ]; then
	AOUTPUTDIR=${EXPERIMENT}/Analysis/Cluster/ActiveTask/${SUBJ}
	mkdir -p ${AOUTPUTDIR}
	cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUN}
	bxhreorient --orientation LAS run*${RUN}.bxh reoriented_run${RUN2}.bxh
	bxh2analyze -s --nii reoriented_run${RUN2}.bxh ${AOUTPUTDIR}/run${RUN2}
	else
	POUTPUTDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}
	mkdir -p ${POUTPUTDIR}
	cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUN}
	bxhreorient --orientation LAS run*${RUN}.bxh reoriented_run${RUN2}.bxh
	bxh2analyze -s --nii reoriented_run${RUN2}.bxh ${POUTPUTDIR}/run${RUN2}
	fi
fi
done
done

OUTDIR=${EXPERIMENT}/Analysis/Cluster/Job_logs



# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
