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

FSLDATADIR2=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}/PrestatsOnly/${SUBJ}_prestats6mm_noST/${SUBJ}_prestatsonly${run}.feat
ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}
MAINOUTPUT=${MAINDIR}/${SUBJ}_Model5_NoMotor_${SMOOTH}mm_noST_v${AUTOVERSION}
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates

mkdir -p ${MAINOUTPUT}

#DATA=${FSLDATADIR2}/${OPTION}_removed_data_v${AUTOVERSION}.nii.gz
DATA=${FSLDATADIR2}/masked_filtered_func_data.nii
OUTPUT=${MAINOUTPUT}/${SUBJ}_run${run}_${OPTION}
OUTPUTREAL=${OUTPUT}.feat

FSLEVDIR=${EXPERIMENT}/Analysis/FSL/EV_Logs_3-7-08_new/Model_2.1/${SUBJ}/Passive


cd ${TEMPLATEDIR}
let "run2=${run}-1"
HOT=${FSLEVDIR}/Run${run2}/Run${run2}_Hot_${SUBJ}.txt
NOT=${FSLEVDIR}/Run${run2}/Run${run2}_Not_${SUBJ}.txt
GAIN=${FSLEVDIR}/Run${run2}/Run${run2}_Gain_${SUBJ}.txt
LOSS=${FSLEVDIR}/Run${run2}/Run${run2}_Loss_${SUBJ}.txt

NEUTRALFACE=${FSLEVDIR}/Run${run2}/Run${run2}_NeutralFace_${SUBJ}.txt
NEUTRALMONEY=${FSLEVDIR}/Run${run2}/Run${run2}_NeutralMoney_${SUBJ}.txt

MOTOR=${FSLEVDIR}/Run${run2}/Run${run2}_MotorResponse_${SUBJ}.txt

if [ -e $MOTOR ]; then
	MOTORCONVOLVE=3
	MOTORSHAPE=3
else
	MOTORCONVOLVE=0
	MOTORSHAPE=10
fi


for i in 'template_noTD_nm_new.fsf'; do
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@GAIN@'$GAIN'@g' \
	-e 's@LOSS@'$LOSS'@g' \
	-e 's@HOT@'$HOT'@g' \
	-e 's@NOT@'$NOT'@g' \
	-e 's@NEUTRALMONEY@'$NEUTRALMONEY'@g' \
	-e 's@NEUTRALFACE@'$NEUTRALFACE'@g' \
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
