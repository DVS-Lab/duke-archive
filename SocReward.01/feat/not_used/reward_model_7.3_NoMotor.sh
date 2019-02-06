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

SUBJ=$1
run=$2
SMOOTH=$3
AUTOVERSION=$4
OPTION=$5


FSLDATADIR2=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}/${SUBJ}_ica_${SMOOTH}mm_ST/${SUBJ}_run${run}.ica
ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}
MAINOUTPUT=${MAINDIR}/${SUBJ}_Model7.3_NoMotor_${SMOOTH}mm_ST_v${AUTOVERSION}
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates/feat

mkdir -p ${MAINOUTPUT}

#DATA=${FSLDATADIR2}/${OPTION}_removed_data_v${AUTOVERSION}.nii.gz
DATA=${FSLDATADIR2}/crap_removed_data_v0.7.1.nii.gz
OUTPUT=${MAINOUTPUT}/${SUBJ}_run${run}_${OPTION}
OUTPUTREAL=${OUTPUT}.feat

FSLEVDIR=${EXPERIMENT}/Analysis/FSL/EV_Logs_3-10-08_new/Model_7.3_new/${SUBJ}/Passive


cd ${TEMPLATEDIR}
let "run2=${run}-1"
POSFACE=${FSLEVDIR}/Run${run2}/Run${run2}_PosFace_${SUBJ}.txt
NEGFACE=${FSLEVDIR}/Run${run2}/Run${run2}_NegFace_${SUBJ}.txt
POSMONEY=${FSLEVDIR}/Run${run2}/Run${run2}_PosMoney_${SUBJ}.txt
NEGMONEY=${FSLEVDIR}/Run${run2}/Run${run2}_NegMoney_${SUBJ}.txt


MOTORRESPONSE=${FSLEVDIR}/Run${run2}/Run${run2}_MotorResponse_${SUBJ}.txt

if [ -e $MOTORRESPONSE ]; then
	CONVOLVE=3
	SHAPE=3
else
	CONVOLVE=0
	SHAPE=10
fi


for i in 'reward_model_7_template_NoMotor.fsf'; do
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@POSFACE@'$POSFACE'@g' \
	-e 's@NEGFACE@'$NEGFACE'@g' \
	-e 's@POSMONEY@'$POSMONEY'@g' \
	-e 's@NEGMONEY@'$NEGMONEY'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@DATA@'$DATA'@g' \
	<$i> ${MAINOUTPUT}/FEAT_0${run}.fsf
done


cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	echo "That one is already done!"
else
	feat ${MAINOUTPUT}/FEAT_0${run}.fsf
	cd ${OUTPUTREAL}
	rm -f filtered_func_data.nii.gz
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
