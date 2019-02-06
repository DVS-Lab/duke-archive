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


SUBJ=SUB_SUBNUM_VAR
RUN=SUB_RUN_VAR
SMOOTH=SUB_SMOOTH_VAR
GO=SUB_GO_VAR

FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh


ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
MAINDIR=${EXPERIMENT}/Analysis/Cluster/SVM_PassiveTask/${SUBJ}
MAINDIR2=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance/${SUBJ}
MAINOUTPUT=${MAINDIR2}/PrestatsOnly2/${SUBJ}_prestats_Smooth_${SMOOTH}mm
mkdir -p $MAINOUTPUT
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance/AnalysisTemplates/NEW_FSL_4p1
OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat

STANDARD=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance/ROIs_NEW/standard_4mm.nii.gz

if [ $GO -eq 1 ];then
	rm -rf ${OUTPUTREAL}
fi

DATA=${MAINDIR}/run${RUN}.nii.gz
OUTPUT=${MAINOUTPUT}/run${RUN}


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

cd ${TEMPLATEDIR}
 for i in prestats.fsf; do
 sed -e 's@OUTPUT@'$OUTPUT'@g' \
     -e 's@NVOLUMES@'$NVOLUMES'@g' \
     -e 's@NDISDAQS@'$NDISDAQS'@g' \
     -e 's@STANDARD@'$STANDARD'@g' \
     -e 's@SMOOTH@'$SMOOTH'@g' \
     -e 's@ANAT@'$ANAT'@g' \
     -e 's@DATA@'$DATA'@g' <$i> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
 done

cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
echo "That one is already done!"
else
feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi
 
OUTDIR=${MAINOUTPUT}/Cluster_Logs
mkdir -p $OUTDIR

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