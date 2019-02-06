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
GO=1
SPACE="native"
AR1=1
OPTION=4

FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh


MAINDIR=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance
SUBJDIR=${MAINDIR}/${SUBJ}

# S:\Analysis\Cluster\forAlon_NeuralFinance\32918\NEW_ANALYSES\32918_FEAT_native_6mm_PERM1

if [ $AR1 -eq 1 ]; then
	TEMPLATE=SocReward01_stats_junk.fsf
	MAINOUTPUT=${SUBJDIR}/TEST/NEW_ANALYSES2/${SUBJ}_FEAT_native_6mm_PERM${OPTION}
else
	TEMPLATE=SocReward01_stats_noAR1.fsf
	MAINOUTPUT=${SUBJDIR}/NEW_ANALYSES2/${SUBJ}_FEAT_native_6mm_PERM${OPTION}_noAR1
fi

OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
OUTPUT=${MAINOUTPUT}/run${RUN}
mkdir -p ${MAINOUTPUT}

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUTREAL}
fi

ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz

let "run2=${RUN}-1"
FSLEVDIR=${EXPERIMENT}/Analysis/FSL/EV_Logs_3-10-08_new/Model_6/${SUBJ}/Passive
REGRESSOR=${FSLEVDIR}/Run${run2}/Run${run2}_Face_${SUBJ}.txt

MAINDIR2=${EXPERIMENT}/Analysis/Cluster/SVM_PassiveTask/${SUBJ}
DATA=${MAINDIR2}/run${RUN}.nii.gz
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance/AnalysisTemplates/NEW_FSL_4p1

# DATA=${MAINDIR}/NEWDATA2/smooth6mm/permutation${OPTION}/native/${SUBJ}/data_run${RUN}.nii.gz
# 
# if [ $SUBJ -eq 32904 ]; then
# 	NDISDAQS=6
# 	NVOLUMES=120
# else
# 	NVOLUMES=122
# 	NDISDAQS=8
# fi
# 
# if [ $SUBJ -eq 33456 ] && [ $RUN -lt 4 ]; then
# 	NDISDAQS=4
# 	NVOLUMES=118
# 	DATA=${MAINDIR2}/xrun${RUN}.hdr
# fi


NDISDAQS=8
NVOLUMES=122

cd ${TEMPLATEDIR}

STANDARD=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance/ROIs_NEW/standard_4mm.nii.gz

 for i in $TEMPLATE; do
 sed -e 's@OUTPUT@'$OUTPUT'@g' \
     -e 's@NVOLUMES@'$NVOLUMES'@g' \
     -e 's@NDISDAQS@'$NDISDAQS'@g' \
     -e 's@SMOOTH@'$SMOOTH'@g' \
     -e 's@REGRESSOR@'$REGRESSOR'@g' \
     -e 's@ANAT@'$ANAT'@g' \
     -e 's@STANDARD@'$STANDARD'@g' \
     -e 's@FUNC@'$DATA'@g' <$i> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
 done




cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	echo "That one is already done!"
else
	feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
	cd $OUTPUTREAL
	rm -rf filtered_func_data.nii.gz
	rm -rf stats/res4d.nii.gz
fi

OUTDIR=${MAINOUTPUT}/Logs
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
