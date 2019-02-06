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
#$ -M smith@biac.duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

F_VALUE=0.45
#SMOOTHNUM=$2
#AUTONUM=$2
SMOOTH=$1

for SUBJ in 32953; do # 32958 32976 32984 33035 33045 33064 33082 33135 33288 33302 33402 33744 33467 33642 33669 33732 33746 33754 33757 33771 33784 33456; do
	for RUN in 2; do # 3 4 5 6; do
	FSLDATADIR2=${EXPERIMENT}/Analysis/Cluster/PassiveTask/$SUBJ
	MAINDIR=$FSLDATADIR2
	MAINOUTPUT=${MAINDIR}/${SUBJ}_ica_pt00_noBET_${SMOOTH}mm
	OUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN}
	REALOUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN}.ica
 	cd $REALOUTPUT
	
	#BETINPUT=mean_func.nii.gz
	#BETOUTPUT=new_mean_func_betp${F_VALUE}
	#BETCMD="bet $BETINPUT $BETOUTPUT -f ${F_VALUE} -m"
	
	#eval $BETCMD
	
	
	#bxh2analyze -s -b --nii new_masked_func_data_a${AUTONUM}_f${F_VALUE}.bxh func_data_a${AUTONUM}_f${F_VALUE}
	fslerrorreport
	#exit 222
	
	done
done



# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${EXPERIMENT}/Analysis/error_report
mkdir -p $OUTDIR
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
