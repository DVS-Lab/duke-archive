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
# #$ -M SUB_USEREMAIL_SUB

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

FSLDIR=/usr/local/fsl-4.1.3-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh


SUBJ=SUB_SUBNUM_VAR
run=SUB_RUN_VAR
CONDITION=SUB_CONDITION_VAR
GO=SUB_GO_VAR
ROI=SUB_ROI_VAR
MODEL=SUB_MODEL_VAR

RUN=$run

SMOOTH=6
FSLDATADIR2=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}/${SUBJ}_ica_${SMOOTH}mm_ST/${SUBJ}_run${run}.ica
ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates/PPI
DATA=${FSLDATADIR2}/crap_removed_data_v0.7.1.nii.gz
cd ${TEMPLATEDIR}
let "run2=${run}-1"

if [ "$SUBJ" == "33732" ] && [ "$RUN" == "4" ]; then
	exit
fi

FSLEVDIR=${EXPERIMENT}/Analysis/FSL/PPI/${MODEL}/${SUBJ}/Passive

#Y:\Huettel\SocReward.01\Analysis\Cluster\PassiveTask\32918\forPPI\standard2func_run2
#Y:\Huettel\SocReward.01\Analysis\FSL\PPI\Linear_Increase\32918\Passive\Run1

if [ "$CONDITION" == "Face" ]; then
	MAINOUTPUT=${MAINDIR}/${SUBJ}_${MODEL}_Face_PPI_$ROI
	CONSTANT=${FSLEVDIR}/Run${run2}/Run${run2}_Face_constant_${SUBJ}.txt
	SCALED=${FSLEVDIR}/Run${run2}/Run${run2}_Face_scaled_${SUBJ}.txt
elif [ "$CONDITION" == "Money" ]; then
	MAINOUTPUT=${MAINDIR}/${SUBJ}_${MODEL}_Money_PPI_$ROI
	CONSTANT=${FSLEVDIR}/Run${run2}/Run${run2}_Money_constant${SUBJ}.txt
	SCALED=${FSLEVDIR}/Run${run2}/Run${run2}_Money_scaled_${SUBJ}.txt
fi
MOTOR=${FSLEVDIR}/Run${run2}/Run${run2}_MotorResponse_${SUBJ}.txt

#Y:\Huettel\SocReward.01\Analysis\Cluster\PassiveTask\32918\forPPI\standard2func_run2
PHYS=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}/forPPI/standard2func_run${RUN}/${ROI}.txt
#choice_mOFC_2mm_ts.txt
#overlap_vmPFC_2mm_ts.txt

mkdir -p ${MAINOUTPUT}
OUTPUT=${MAINOUTPUT}/${SUBJ}_run${run}
OUTPUTREAL=${OUTPUT}.feat
if [ $GO -eq 1 ]; then
	rm -rf $OUTPUTREAL
fi

if [ -e $MOTOR ]; then
	for i in 'PPI.fsf'; do
		sed -e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@SCALED@'$SCALED'@g' \
		-e 's@CONSTANT@'$CONSTANT'@g' \
		-e 's@ANAT@'$ANAT'@g' \
		-e 's@DATA@'$DATA'@g' \
		-e 's@PHYS@'$PHYS'@g' \
		-e 's@MOTOR@'$MOTOR'@g' \
		<$i> ${MAINOUTPUT}/FEAT_0${run}.fsf
	done
else
	for i in 'PPI_noMotor.fsf'; do
		sed -e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@SCALED@'$SCALED'@g' \
		-e 's@CONSTANT@'$CONSTANT'@g' \
		-e 's@ANAT@'$ANAT'@g' \
		-e 's@DATA@'$DATA'@g' \
		-e 's@PHYS@'$PHYS'@g' \
		<$i> ${MAINOUTPUT}/FEAT_0${run}.fsf
	done
fi

cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	echo "That one is already done!"
else
	feat ${MAINOUTPUT}/FEAT_0${run}.fsf
	cd ${OUTPUTREAL}
	rm -f filtered_func_data.nii.gz
	rm -f stats/res4d.nii.gz
fi
 
OUTDIR=${MAINOUTPUT}/logs
mkdir -p ${OUTDIR}



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
