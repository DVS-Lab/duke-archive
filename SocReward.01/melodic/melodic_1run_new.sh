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

MAINDIR=${EXPERIMENT}/Analysis/Cluster/SVM_PassiveTask/$SUBJ
ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
MAINOUTPUT2=${MAINDIR}/${SUBJ}_MELODIC_NoSmooth_FEAT_UPDATE
MAINOUTPUT=${MAINDIR}/${SUBJ}_MELODIC_NoSmooth_FEATupdate
rm -rf $MAINOUTPUT2
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates
DATA=${MAINDIR}/run${RUN}.nii.gz
mkdir -p ${MAINOUTPUT}

OUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN}
REALOUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN}.ica

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
 for i in melodic_template_normal.fsf; do
 sed -e 's@OUTPUT@'$OUTPUT'@g' \
     -e 's@NVOLUMES@'$NVOLUMES'@g' \
     -e 's@NDISDAQS@'$NDISDAQS'@g' \
     -e 's@ANAT@'$ANAT'@g' \
     -e 's@DATA@'$DATA'@g' <$i> ${MAINOUTPUT}/melodic_${RUN}.fsf
 done


cd ${MAINOUTPUT}
if [ -d "$REALOUTPUT" ]; then
 echo "that one is done!"
exit
else
 feat ${MAINOUTPUT}/melodic_${RUN}.fsf
fi

OUTDIR=${MAINOUTPUT}/logs
mkdir -p $OUTDIR



# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=$MAINOUTPUT
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.${JOB_ID}_$SUBJ_${RUN}_${HOSTNAME}.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
