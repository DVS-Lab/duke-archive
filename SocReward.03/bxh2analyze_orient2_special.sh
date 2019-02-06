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
 
# Need to input global EXPERIMENT, and inputs BXHINFILE, OUTDIR and OUTPRE
# BXHINFILE is the input file to convert
# OUTDIR is where the output folder will go
# OUTPRE is the output prefix of the data
# Example:
# qsub -v EXPERIMENT=Dummy.01 qsub_bxh2analyze \
# EXPERIMENT/Data/Func/99999/run01/run001.bxh EXPERIMENT/Data/Func/99999/fsl4D run01
 
 
#"20070328_32904 32904 11" 
 
#for LIST in "20070403_32918 32918 11"; do

#set -- $LIST
SUBJ_FULL=$1
SUBJ=$2
NUMRUNS=$3
PASSIVE=$4
PASSIVE_CUED=$5
ACTIVE=$6
REST=$7
ANAT_SERIES=$8

set -- $REST
REST=$1
REST_RUNS=$2

let PASSIVE_STOP=$PASSIVE+3
#PASSIVE_STOP=7
let PASSIVE_CUED_STOP=$PASSIVE_CUED+1
let ACTIVE_STOP=$ACTIVE+2
let REST_STOP=$REST+$REST_RUNS


MAINFUNCDIR=${EXPERIMENT}/Data/Func
MAINANATDIR=${EXPERIMENT}/Data/Anat
NEWANATDIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}
mkdir -p $NEWANATDIR

cd $MAINANATDIR/${SUBJ_FULL}/${ANAT_SERIES}
rm -rf ${SUBJ}_reoriented_anat.bxh
rm -rf ${SUBJ}_reoriented_anat.dat

bxhreorient --orientation LAS series*.bxh ${SUBJ}_reoriented_anat.bxh
bxh2analyze -s -b --niigz ${SUBJ}_reoriented_anat.bxh $NEWANATDIR/${SUBJ}_anat
rm -rf ${SUBJ}_reoriented_anat.bxh
rm -rf ${SUBJ}_reoriented_anat.dat

cd $NEWANATDIR
bet ${SUBJ}_anat ${SUBJ}_anat_brain -f 0.35

R1=0; R2=0; R3=0; R4=0;
for RUNS in `seq $NUMRUNS`; do
	if [ $RUNS -ge $PASSIVE ] && [ $RUNS -lt $PASSIVE_STOP ];then
	#if [ $RUNS -eq 1 ] || [ $RUNS -eq 2 ] || [ $RUNS -eq 7 ];then
		let R1=$R1+1
		PASSOUTDIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/Passive
		mkdir -p ${PASSOUTDIR}
		cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUNS}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
		bxhreorient --orientation LAS run*${RUNS}.bxh reoriented_run${RUNS}.bxh
		bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${PASSOUTDIR}/run${R1}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat

	fi

	if [ $RUNS -ge $PASSIVE_CUED ] && [ $RUNS -lt $PASSIVE_CUED_STOP ];then
		let R2=$R2+1
		PASSCUEDOUTDIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/PassiveCued
		mkdir -p ${PASSCUEDOUTDIR}
		cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUNS}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
		bxhreorient --orientation LAS run*${RUNS}.bxh reoriented_run${RUNS}.bxh
		bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${PASSCUEDOUTDIR}/run${R2}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat

	fi

	if [ $RUNS -ge $ACTIVE ] && [ $RUNS -lt $ACTIVE_STOP ];then
		let R3=$R3+1
		AOUTPUTDIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/Active
		mkdir -p ${AOUTPUTDIR}
		cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUNS}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
		bxhreorient --orientation LAS run*${RUNS}.bxh reoriented_run${RUNS}.bxh
		bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${AOUTPUTDIR}/run${R3}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat

	fi

	if [ $RUNS -ge $REST ] && [ $RUNS -lt $REST_STOP ];then
		let R4=$R4+1
		RESTOUTDIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/Resting
		mkdir -p ${RESTOUTDIR}
		cd ${MAINFUNCDIR}/${SUBJ_FULL}/run*${RUNS}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat
		bxhreorient --orientation LAS run*${RUNS}.bxh reoriented_run${RUNS}.bxh
		bxh2analyze -s -b --niigz reoriented_run${RUNS}.bxh ${RESTOUTDIR}/run${R4}
		rm -rf reoriented_run${RUNS}.bxh
		rm -rf reoriented_run${RUNS}.dat

	fi

done



OUTDIR=${EXPERIMENT}/Analysis/FSL/Job_logs
mkdir -p $OUTDIR

# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
