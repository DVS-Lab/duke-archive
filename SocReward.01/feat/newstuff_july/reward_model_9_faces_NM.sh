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
RUN=$2
run=$RUN


ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
MAINDIR=${EXPERIMENT}/Analysis/Cluster/SVM_PassiveTask/${SUBJ}
MAINDIR2=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}

MAINOUTPUT=${MAINDIR2}/${SUBJ}_NaN_test_FEAT_final
OUTPUT=${MAINOUTPUT}/${SUBJ}_faces_${RUN}

TEMPLATE=reward_model_9_faces_template_NoMotor_new.fsf
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates/feat

mkdir -p ${MAINOUTPUT}

OUTPUTREAL=${OUTPUT}.feat
if [ -d "$OUTPUTREAL" ]; then
	cd $OUTPUTREAL
	if [ ! -e cluster_mask_zstat1.nii.gz ]; then
		rm -rf $OUTPUTREAL
	fi
fi


DATA=${MAINDIR}/run${RUN}.nii.gz

 
if [ $SUBJ -eq 32904 ]; then
	NDISDAQS=6
	NVOLUMES=120
else
	NVOLUMES=122
	NDISDAQS=8
fi
 
if [ $SUBJ -eq 33456 ] && [ $RUN -lt 4 ]; then
NDISDAQS=4
NVOLUMES=118
DATA=${MAINDIR}/xrun${RUN}.hdr
fi

FSLEVDIR=${EXPERIMENT}/Analysis/FSL/EV_Logs_3-7-08_new/Model_1/${SUBJ}/Passive


cd ${TEMPLATEDIR}
let "run2=${run}-1"

ONESTAR=${FSLEVDIR}/Run${run2}/Run${run2}_OneStar_${SUBJ}.txt
TWOSTAR=${FSLEVDIR}/Run${run2}/Run${run2}_TwoStar_${SUBJ}.txt
THREESTAR=${FSLEVDIR}/Run${run2}/Run${run2}_ThreeStar_${SUBJ}.txt
FOURSTAR=${FSLEVDIR}/Run${run2}/Run${run2}_FourStar_${SUBJ}.txt


MOTOR=${FSLEVDIR}/Run${run2}/Run${run2}_MotorResponse_${SUBJ}.txt



for i in $TEMPLATE; do
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	-e 's@NDISDAQS@'$NDISDAQS'@g' \
	-e 's@ONESTAR@'$ONESTAR'@g' \
	-e 's@TWOSTAR@'$TWOSTAR'@g' \
	-e 's@THREESTAR@'$THREESTAR'@g' \
	-e 's@FOURSTAR@'$FOURSTAR'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@DATA@'$DATA'@g' \
	<$i> ${MAINOUTPUT}/fFEAT_0${run}.fsf
done


cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	echo "That one is already done!"
else
	feat ${MAINOUTPUT}/fFEAT_0${run}.fsf
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
