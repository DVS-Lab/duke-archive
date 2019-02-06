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


FSLDATADIR2=${EXPERIMENT}/Analysis/Cluster/PassiveTask/$SUBJ
ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
MAINDIR=$FSLDATADIR2
MAINOUTPUT=${MAINDIR}/${SUBJ}_ica_noBET
TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates


if [ $RUN -eq 2 ]
then
BETINPUT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat.nii
BETOUTPUT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain
bet $BETINPUT $BETOUTPUT -f 0.3 -g 0
mkdir -p ${MAINOUTPUT}
fi

if [ "$RUN" -le 2 ] && [ "$SUBJ" -eq 33456 ]; then
 DATA=${FSLDATADIR2}/xrun${RUN}.hdr
else
 DATA=${FSLDATADIR2}/run${RUN}.nii
fi

 OUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN}
 REALOUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN}.ica
 
 #makes the fsf files from the template fsf file
cd ${TEMPLATEDIR}
if [ "$RUN" -le 2 ] && [ "$SUBJ" -eq 33456 ]; then
 
 for i in 'melodic_nostats_new33456_noBET.fsf'; do
  sed -e 's@OUTPUT@'$OUTPUT'@g' \
   -e 's@ANAT@'$ANAT'@g' \
   -e 's@DATA@'$DATA'@g' <$i> ${MAINOUTPUT}/melodic_${RUN}.fsf
 done

else

 for i in 'melodic_nostats_new_noBET.fsf'; do
  sed -e 's@OUTPUT@'$OUTPUT'@g' \
   -e 's@ANAT@'$ANAT'@g' \
   -e 's@DATA@'$DATA'@g' <$i> ${MAINOUTPUT}/melodic_${RUN}.fsf
 done
 
fi

cd ${MAINOUTPUT}
 #runs the analysis using the newly created fsf files
 if [ -d "$REALOUTPUT" ]; then
 echo "that one is done!"
 else
 feat ${MAINOUTPUT}/melodic_${RUN}.fsf
 fi
 echo $MAINOUTPUT
 echo $OUTPUT
 echo $DATA
 echo $TEMPLATEDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${EXPERIMENT}/Analysis/Cluster/Job_logs
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
